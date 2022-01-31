package com.wolper.services;



import com.wolper.domain.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import javax.persistence.*;
import java.util.*;




@Repository(value = "getuserinfo")
@Transactional(readOnly = true)
public class GetUserInfoService {




    @PersistenceContext
    EntityManager em;

    @Autowired
    DateConverterAndValidator journalValidator;


    Logger logger = LoggerFactory.getLogger(GetUserInfoService.class);


    //select student data
    public String getStudentInfo(String login) {

        if(login==null || login.isEmpty()) return "Error!";
        UsersEntity ue;
        ue = em.find(UsersEntity.class, login);
        if (ue == null) return "Error!";
        return ue.getFirstName() + " " + ue.getSecondName();
    }




    //select prepod data
    public Set<SubjectClassLists> getPrepodInfo(String login) {

        if (login==null) return null;

        //query
        List<PrepodEntity> pe = em.createNamedQuery("findPrepodGeneralInfo", PrepodEntity.class)
                .setParameter("login", login).getResultList();
        //filling in lightweight auxiliary class
        return SubjectClassLists.listAdapter(pe);
    }



    //select prepod data by subject
    public PrepodEntity getPrepodInfo(String login, String subj) {
        if ((login==null)||(subj==null))return null;

        //query
        PrepodEntity pe = em.createNamedQuery("findPrepodInfoBySubject", PrepodEntity.class)
                .setParameter("login", login)
                .setParameter("subject", subj)
                .getSingleResult();
        pe.setClasses(null);
        pe.setLogin(null);
        return pe;
    }




    //save prepod data
    @Transactional(readOnly = false)
    public String setPrepodInfo(String login, PrepodEntity prepodEntity) {

        if(prepodEntity==null) return "Error!";
        PrepodEntity pre = em.getReference(PrepodEntity.class, prepodEntity.getId());
        pre.setTopics(prepodEntity.getTopics());
        pre.setWorks(prepodEntity.getWorks());
        return "ok";
    }





    //select journal for subject class and date
    @Transactional(readOnly = false)
    public List<JournalEntity> getJournalInfo(String login, String form, String subject, String date, boolean allow_create) {


        if ((login==null)||(subject==null))return null;
        if ((allow_create) && ((date==null))) return null;

        //convert date for prepod - from specified date, for sdudent from report date
        Calendar calendar = allow_create?journalValidator.creatCalendar(date, allow_create) : journalValidator.getReportYear();

        //query dependinly who has come pretod (allow_create=true) of student (false)
        String query=allow_create?"findJlGeneralInfo":"findJlStudentInfo";
        String paramName=allow_create?"form":"login";
        String param=allow_create?form:login;

        //query
        List<JournalEntity> je;
        je = em.createNamedQuery(query, JournalEntity.class)
                .setParameter("subj", subject)
                .setParameter(paramName, param)
                .setParameter("date", calendar.getTime(), TemporalType.DATE)
                .getResultList();



        //if journal list is absent - to create
        if (je.isEmpty()) {
            if (!allow_create) return null;

            //it is possible only for sertain prepod, so lets check it's login
            if (!checkLogin(login, subject, form)) return null;
            //creating empty page of the journal
            Set<UsersEntity> usersEntities = getStudentsList(form);
            if (usersEntities==null || usersEntities.isEmpty()) return null;
            je = new ArrayList();
            for (UsersEntity ue : usersEntities) {
                JournalEntity journalEntity = JournalEntity.factory(subject, calendar, form, ue);
                //persist, get id and then
                em.persist(journalEntity);
                //add to result list
                je.add(journalEntity);
            }
        }
        return je;
    }





    //select student list for class
    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    public Set<UsersEntity> getStudentsList(String form) {

        if (form==null) return null;

        //query
        ClassEntity ce=null;
        try {
            ce = em.createNamedQuery("getStudentsList", ClassEntity.class)
                    .setParameter("form", form)
                    .setHint(org.hibernate.annotations.QueryHints.READ_ONLY, true)
                    .getSingleResult();
        } catch (NoResultException pe) {return null;}
        if (ce==null) return null;
        //clean persistent contecst from extra info
        em.detach(ce);
        return ce.getStudents();
    }





    //save journal data
    @Transactional(readOnly = false, rollbackFor = Exception.class)
    public String setJournalInfo(JournalList [] journalLists, String date, String subj, String form, String login) {

        if ((journalLists==null) || (journalLists.length==0)) return null;

        //check right right to access the journal for specific subject
        if (!checkLogin(login, subj, form)) throw new AccessDeniedException("Cheater!!!");

        //parse the calendar
        Calendar calendar = journalValidator.creatCalendar(date, true);

        for(JournalList jl : journalLists) {
            em.createNamedQuery("updateJLForStudent")
                //update
                .setParameter("mark", jl.getMark())
                .setParameter("work", jl.getWork())
                .setParameter("topic", jl.getTopic())
                .setParameter("comment", jl.getComment())
                .setParameter("show_d", jl.isShow_date())
                .setParameter("present", jl.isPresent())
                //where (unique)
                .setParameter("date", calendar, TemporalType.DATE)
                .setParameter("subject", jl.getSubject())
                .setParameter("student", jl.getLogin())
                .executeUpdate();
        }
        return "ok";
    }




    //select subjects list for student
    public List<String> getSubjectsList(String student) {

        if (student==null) return null;

        //query
        //list off subjects for a student within a school year
        Calendar start_date = journalValidator.getReportYear();
        List<String> list = em.createNamedQuery("selectSubjectsForStudent", String.class)
                .setParameter("student", student)
                .setParameter("date_st", start_date)
                .getResultList();
        return list;
    }




    //select marks list for year report
    public List<JournalEntity> getReportData(String subj, String form) {

        if (subj==null || form==null) return null;

        Calendar calendar = journalValidator.getReportYear();

        //query
        //get marks for a period form and subject
        return  em.createNamedQuery("selectJLforBigReport", JournalEntity.class)
                .setParameter("date", calendar, TemporalType.DATE)
                .setParameter("subject", subj)
                .setParameter("form", form)
                .getResultList();
    }






    //checklogin for subject and form
    @Transactional(readOnly = true, propagation = Propagation.SUPPORTS)
    private  boolean checkLogin(String login, String subject, String form) {
        //chech if generally prepod teaches such subject
        List<PrepodEntity> pe = em.createNamedQuery("selectSubjectsForPrepod", PrepodEntity.class)
                .setParameter("subject", subject)
                .setParameter("login", login)
                .setHint(org.hibernate.annotations.QueryHints.READ_ONLY, true)
                .getResultList();
        if ((pe==null) || pe.isEmpty()) {
            throw new AccessDeniedException("Cheater!!!");
        }
        //check for a specific class
        boolean checked=false;
        for (PrepodEntity p: pe) {
            Collection<ClassEntity> ce =p.getClasses();
            for (ClassEntity c : ce) {
                if (c.getClassname().equals(form)) checked=true;
                em.detach(c);
            }
            //clean persistent context from extra info
            em.detach(p);
        }
        if (!checked) throw new AccessDeniedException("Cheater!!!");
        return true;
    }
}