package com.wolper.domain;




import javax.persistence.*;
import javax.persistence.Entity;
import javax.persistence.Table;
import javax.validation.constraints.Max;
import javax.validation.constraints.Min;
import javax.validation.constraints.Size;
import java.io.Serializable;
import java.util.Calendar;


//main journal - the goal of the application

@Entity(name = "JournalEntity")
@Table(name = "journal",  schema = "public", catalog = "fmh", uniqueConstraints= @UniqueConstraint(columnNames={"date", "stud_login", "subject"}))



public class JournalEntity implements Serializable{


    private long id;
    private Calendar date;
    private String form;
    private UsersEntity student;
    private int mark=0;
    private boolean present=true;
    private boolean show_date=true;
    private String subject;
    private String topic;
    private String work;
    private String comment;



    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE)
    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    @Column(name="date")
    @Temporal(TemporalType.DATE)
    public Calendar getDate() {
        return date;
    }

    public void setDate(Calendar date) {this.date = date;}

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "stud_login", nullable = false)
    public UsersEntity getStudent() {
        return student;
    }

    public void setStudent(UsersEntity student) {
        this.student = student;
    }

    @Column(name = "mark", nullable = false)
    @Min(0) @Max(12)
    public int getMark() {
        return mark;
    }

    public void setMark(int mark) {
        this.mark = mark;
    }

    @Column(name = "present", nullable = false, columnDefinition = "boolean default true")
    public boolean isPresent() {
        return present;
    }

    public void setPresent(boolean present) {
        this.present = present;
    }

    @Column(name = "show_date", nullable = false, columnDefinition = "boolean default true")
    public boolean isShow_date() {
        return show_date;
    }

    public void setShow_date(boolean show_date) {
        this.show_date = show_date;
    }

    @Column(name = "topic")
    @Size(max=25)
    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    @Column(name = "work")
    @Size(max=25)
    public String getWork() {
        return work;
    }

    public void setWork(String work) {
        this.work = work;
    }

    @Column(name = "subject", nullable = false, insertable = true, updatable = false)
    @Size(max=30)
    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    @Column(name = "comment")
    @Size(max=40)
    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    @Column(name = "class_name", nullable = false)
    @Size(max=8)
    public String getForm() {return form;}

    public void setForm(String form) {this.form = form;}



    //factory
    public static JournalEntity factory(String subject, Calendar localDate, String form, UsersEntity ue) {
        JournalEntity je = new JournalEntity();
        je.setSubject(subject);
        je.setDate(localDate);
        je.setPresent(true);
        je.setShow_date(true);
        je.setMark(0);
        je.setForm(form);
        je.setStudent(ue);
        return je;
    }




    //equal and hash
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        JournalEntity that = (JournalEntity) o;

        if (date != null ? !date.equals(that.date) : that.date != null) return false;
        if (student != null ? !student.equals(that.student) : that.student != null) return false;
        return subject != null ? subject.equals(that.subject) : that.subject == null;

    }

    @Override
    public int hashCode() {
        int result = date != null ? date.hashCode() : 0;
        result = 31 * result + (student != null ? student.hashCode() : 0);
        result = 31 * result + (subject != null ? subject.hashCode() : 0);
        return result;
    }
}
