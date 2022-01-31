package com.wolper.domain;



import org.hibernate.annotations.*;
import org.hibernate.annotations.CascadeType;

import javax.persistence.*;
import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OrderBy;
import javax.persistence.Table;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Set;
import java.util.TreeSet;


//class for saving information concerning schedule (prepod + subject + class) as well as works and topics
@Entity


@NamedQueries({
        @NamedQuery(name = "findPrepodGeneralInfo", query = "select p from PrepodEntity p join fetch p.login where p.login.login=:login"),
        @NamedQuery(name = "findPrepodInfoBySubject", query = "select p from PrepodEntity p join fetch p.login where p.login.login=:login and p.subject=:subject order by subject"),
        @NamedQuery(name="findJlGeneralInfo", query="select jr from JournalEntity as jr join fetch jr.student where jr.date=:date and jr.subject=:subj and jr.form=:form order by jr.student.firstName"),
        @NamedQuery(name = "getStudentsList", query = "select distinct ce from ClassEntity ce join fetch ce.students as st where ce.classname=:form order by st.firstName"),
        @NamedQuery(name="findJlStudentInfo", query="from JournalEntity as jr where jr.date>=:date and trim(jr.subject)=trim(:subj) and jr.student.login=:login and (jr.mark<>0 or jr.present=false) order by jr.date"),
        @NamedQuery(name="selectSubjectsForPrepod", query="select p from PrepodEntity as p where p.subject=:subject and p.login.login=:login"),
        @NamedQuery(name="selectSubjectsForStudent", query="select distinct j.subject from JournalEntity as j where j.student.login=:student and (j.mark<>0 or j.present=false) and j.date>:date_st order by j.subject"),
        @NamedQuery(name="updateJLForStudent", query = "update JournalEntity as j set j.mark=:mark, j.work=:work, j.topic=:topic, j.comment=:comment, j.show_date=:show_d, j.present=:present where j.date=:date and j.subject=:subject and j.student.login=:student"),
        @NamedQuery(name="selectJLforBigReport", query = "select j from JournalEntity as j join fetch j.student where j.date>:date and j.subject=:subject and j.form=:form and (j.mark<>0 or j.present=false) order by j.date desc")
})



@Table(name="prepod", uniqueConstraints= @UniqueConstraint(columnNames={"login", "subject"}), schema = "public", catalog = "fmh")
public class PrepodEntity implements Serializable {



    private Long id;
    private UsersEntity login;
    private String subject;
    private Set<String> works=new TreeSet();
    private Set<String> topics=new TreeSet();;
    private Collection<ClassEntity> classes= new ArrayList();




    @Id
    @Column(name = "schedule_id")
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }





    //prepod login
    @OneToOne
    @JoinColumn(name = "login", nullable = false, columnDefinition="VARCHAR(20)")
    public UsersEntity getLogin() {
        return login;
    }

    public void setLogin(UsersEntity login) {
        this.login = login;
    }


    //subject
    @Column(name = "subject", nullable = false, length = 30)
    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }





    //classes for subject

    @ManyToMany
    @BatchSize(size = 10)
    @JoinTable(name = "schedule_AND_class", joinColumns = {@JoinColumn(name = "schedules_id")},
            uniqueConstraints = @UniqueConstraint(columnNames={"schedules_id", "class_name"}),
            inverseJoinColumns = {@JoinColumn(name="class_name")})

    public Collection<ClassEntity> getClasses() {
        return classes;
    }

    public void setClasses(Collection<ClassEntity> classes) {
        this.classes = classes;
    }






    //works and topics lists
    @ElementCollection(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @CollectionTable(name="works", joinColumns=@JoinColumn(name="sched4w_id"))
    @Column(length=25, name = "work", nullable = false)
    @OrderBy(value = "work ASC")
    public Set<String> getWorks() {
        return works;
    }

    public void setWorks(Set<String> works) {
        this.works = works;
    }



    @ElementCollection(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @CollectionTable(name="topics", joinColumns=@JoinColumn(name="sched4t_id"))
    @Column(length=25, name = "topic", nullable = false)
    @OrderBy(value = "topic ASC")
    public Set<String> getTopics() {
        return topics;
    }

    public void setTopics(Set<String> topics) {
        this.topics = topics;
    }





    //hash and equal


    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        PrepodEntity that = (PrepodEntity) o;

        if (login != null ? !login.equals(that.login) : that.login != null) return false;
        return subject != null ? subject.equals(that.subject) : that.subject == null;

    }

    @Override
    public int hashCode() {
        int result = login != null ? login.hashCode() : 0;
        result = 31 * result + (subject != null ? subject.hashCode() : 0);
        return result;
    }
}
