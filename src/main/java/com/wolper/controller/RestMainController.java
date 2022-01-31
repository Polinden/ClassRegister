package com.wolper.controller;



import com.wolper.domain.*;
import com.wolper.services.CheckAutority;
import com.wolper.services.GetUserInfoService;
import com.wolper.services.DateConverterAndValidator;
import com.wolper.services.MyConstrainException;
import org.hibernate.HibernateException;
import org.hibernate.JDBCException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.annotation.*;
import javax.persistence.PersistenceException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.validation.ConstraintViolationException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;



@RestController
public class RestMainController {


    @Autowired
    GetUserInfoService getUserInfoService;

    @Autowired
    CheckAutority checkAutority;

    @Autowired
    DateConverterAndValidator journalValidator;

    Logger logger = LoggerFactory.getLogger(RestMainController.class);


    //get student name
    @RequestMapping(value="/rest/studname/{login}", produces = "text/plain;charset=UTF-8")
    public String studentInfoGet(@PathVariable(value = "login") String login) {
        if (!checkAutority.chechPrepodAndStud(login))  throw new AccessDeniedException("Cheater!!!");

        return getUserInfoService.getStudentInfo(login);
    }


    //get propod general info (subjects and class list)
    @RequestMapping(value="/rest/prepod_get/{login}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public Set<SubjectClassLists> prepodPageGet(@PathVariable(value = "login") String login) {
        if (!checkAutority.chechPrepod(login))  throw new AccessDeniedException("Cheater!!!");
        if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");
        return getUserInfoService.getPrepodInfo(login);
    }


    //get propod info for specifide subject (works and topics)
    @RequestMapping(value="/rest/prepod_get/{login}/{subj}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public PrepodEntity prepodPageGet(@PathVariable(value = "login") String login, @PathVariable(value = "subj") String subj, HttpServletRequest httpServletRequest) {
        if (!checkAutority.chechPrepod(login))  throw new AccessDeniedException("Cheater!!!");
        if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");
        String requestURI = httpServletRequest.getRequestURI();
        String [] mypath = requestURI.split("/");
        subj=decodeHelper(mypath[mypath.length-1]);
        return getUserInfoService.getPrepodInfo(login, subj);
    }


    //save propod info (works and topics)
    @RequestMapping(value="/rest/prepod_set/{login}", consumes = "application/json; charset=UTF-8", produces = "text/html")
    @ResponseBody
    public String prepodPagePost(@PathVariable(value = "login") String login, @RequestBody PrepodEntity prepodEntity) {
        if (!checkAutority.chechPrepod(login))  throw new AccessDeniedException("Cheater!!!");
        if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");
        return getUserInfoService.setPrepodInfo(login, prepodEntity);
    }


    //get journal general info
    @RequestMapping(value="/rest/journal_get/{login}/{form}/{subj}/{date}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<JournalList> journalPageGet(@PathVariable(value = "login") String login,  @PathVariable(value = "subj") String subj,
                                        @PathVariable(value = "form") String form, @PathVariable(value = "date") String date, HttpServletRequest httpServletRequest) {

        if (!checkAutority.chechPrepod(login))  throw new AccessDeniedException("Cheater!!!");
        if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");

        //alas java does not support a charset for path parameter
        String requestURI = httpServletRequest.getRequestURI();
        String [] mypath = requestURI.split("/");
        date=decodeHelper(mypath[mypath.length-1]);
        subj=decodeHelper(mypath[mypath.length-2]);
        form=decodeHelper(mypath[mypath.length-3]);

        List<JournalEntity> journalEntities = getUserInfoService.getJournalInfo(login, form, subj, date, true);
        List<JournalList> journalLists=new ArrayList();
        if (journalEntities==null) return journalLists;
        for (JournalEntity je : journalEntities) {
            JournalList journalList=JournalList.adapter(je);
            journalLists.add(journalList);
        }

        return journalLists;
    }


    //save propod info (works and topics)
    @RequestMapping(value="/rest/journal_set/{login}/{form}/{subj}/{date}", method = RequestMethod.POST, consumes = "application/json; charset=UTF-8", produces = "text/html; charset=UTF-8")
    @ResponseBody
    public String journalPagePost(@PathVariable(value = "login") String login, @PathVariable(value = "subj") String subj,
                                  @PathVariable(value = "form") String form, @PathVariable(value = "date") String date, HttpServletRequest httpServletRequest,
                                  @RequestBody JournalList [] journalLists) {

        if (!checkAutority.chechPrepod(login))  throw new AccessDeniedException("Cheater!!!");
        if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");

        //alas java does not support a charset for path parameter
        String requestURI = httpServletRequest.getRequestURI();
        String [] mypath = requestURI.split("/");
        date=decodeHelper(mypath[mypath.length-1]); subj=decodeHelper(mypath[mypath.length-2]);form=decodeHelper(mypath[mypath.length-3]);

        //validate
        journalValidator.validate(journalLists);
        return getUserInfoService.setJournalInfo(journalLists, date, subj, form, login);
    }



    //get journal student info
    @RequestMapping(value="/rest/journal/{login}/{subj}", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public List<TopicSortedJournal> studentPageGet(@PathVariable(value = "login") String login,  @PathVariable(value = "subj") String subj, HttpServletRequest httpServletRequest) {

        if (!checkAutority.chechPrepodAndStud(login))  throw new AccessDeniedException("Cheater!!!");
        if (checkAutority.checkRole("stud")) if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");

        //alas java does not support a charset for path parameter
        String requestURI = httpServletRequest.getRequestURI();
        String [] mypath = requestURI.split("/");
        subj=decodeHelper(mypath[mypath.length-1]);

        List<JournalEntity> journalEntities = getUserInfoService.getJournalInfo(login, null, subj, null, false);
        List<TopicSortedJournal> journalLists=new ArrayList();
        if (journalEntities==null) return journalLists;
        for (JournalEntity je : journalEntities) {
            TopicSortedJournal topicSortedJournal=TopicSortedJournal.adapter(je);
            journalLists.add(topicSortedJournal);
        }

        return journalLists;
    }



    //get work list
    @RequestMapping(value="/rest/worklist/{login}", produces = "application/json;charset=UTF-8")
    public List<String> subjectsList(@PathVariable(value = "login") String login) {
        if (!checkAutority.chechPrepodAndStud(login))  throw new AccessDeniedException("Cheater!!!");
        if (checkAutority.checkRole("stud")) if (!checkAutority.chechName(login)) throw new AccessDeniedException("Cheater!!!");
        return getUserInfoService.getSubjectsList(login);
    }






    //exceptions handlers

    //security error
    @ResponseStatus(value = HttpStatus.UNAUTHORIZED)
    @ExceptionHandler(value = AccessDeniedException.class) String handlerSecError(HttpServletRequest request, HttpServletResponse htr) {
        logger.info("Злодейское проникновение! С IP="+ request.getRemoteAddr());
        return "Порушення прав доступу!";
    }

    //failed persistance operation
    @ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
    @ExceptionHandler(value = PersistenceException.class) String handlerSecError(PersistenceException pe, HttpServletResponse htr) {
        logger.info("Ошибка работы с базой данныx! "+pe.getMessage()+pe.getCause()+pe.getSuppressed());
        pe.printStackTrace();
        return  "Помилка роботи з базою даних!";
    }

    //failed sql operation
    @ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
    @ExceptionHandler(value = HibernateException.class) String handlerSecError(HibernateException pe, HttpServletResponse htr) {
        if (pe instanceof JDBCException) logger.info("Ошибка работы с базой данныx "+((JDBCException) pe).getSQL()+((JDBCException) pe).getSQLState());
        else logger.info("Ошибка работы с базой данныx! "+pe.getMessage()+pe.getCause()+pe.getSuppressed());
        pe.printStackTrace();
        return  "Помилка роботи з базою даних!";
    }


    //validation exception
    @ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
    @ExceptionHandler(value = MyConstrainException.class) String handlerSecError(MyConstrainException me, HttpServletResponse htr) {
        logger.info("Неверный формат исходных данных! "+me.getErrCode()+me.getErrMsg());
        return  "Невірний формат вихідних даних!";
    }

    //constrain exception
    @ResponseStatus(HttpStatus.NOT_ACCEPTABLE)
    @ExceptionHandler(value = ConstraintViolationException.class) String handlerSecError(ConstraintViolationException me, HttpServletResponse htr) {
        logger.info("Неверный формат исходных данных "+me.getConstraintViolations().toString());
        return  "Невірний формат вихідних даних!";
    }





    //helper
    private String decodeHelper(String s){
        String decodedURI="";
        try {
            decodedURI = URLDecoder.decode(s, "UTF-8");
        } catch (UnsupportedEncodingException e){logger.info("Ошибка кодировки - "+e.getMessage());}
        return decodedURI;
    }

}


