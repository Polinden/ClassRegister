package com.wolper.domain;



//lightweight journal to send to fronend
public class JournalList {


    private Long id=null;
    private String firstname;
    private String secondname;
    private String form;
    private int mark=0;
    private boolean present=true;
    private boolean show_date=true;
    private String subject;
    private String topic;
    private String work;
    private String comment;
    private String login;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getSecondname() {
        return secondname;
    }

    public void setSecondname(String secondname) {
        this.secondname = secondname;
    }

    public int getMark() {
        return mark;
    }

    public void setMark(int mark) {this.mark = mark;}

    public boolean isPresent() {
        return present;
    }

    public void setPresent(boolean present) {
        this.present = present;
    }

    public boolean isShow_date() {
        return show_date;
    }

    public void setShow_date(boolean show_date) {
        this.show_date = show_date;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getWork() {
        return work;
    }

    public void setWork(String work) {
        this.work = work;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getLogin() {return login;}

    public void setLogin(String login) {this.login = login;}


    public String getForm() {return form;}

    public void setForm(String form) {this.form = form;}


    public static JournalList adapter(JournalEntity je){
        JournalList journalList = new JournalList();
        journalList.setId(je.getId());
        journalList.setFirstname(je.getStudent().getFirstName());
        journalList.setSecondname(je.getStudent().getSecondName());
        journalList.setForm(je.getForm());
        journalList.setMark(je.getMark());
        journalList.setPresent(je.isPresent());
        journalList.setShow_date(je.isShow_date());
        journalList.setSubject(je.getSubject());
        journalList.setComment(je.getComment());
        journalList.setWork(je.getWork());
        journalList.setTopic(je.getTopic());
        journalList.setLogin(je.getStudent().getLogin());
        return journalList;
    }


    @Override
    public String toString() {
        return "JournalList{" +
                "id=" + id +
                ", firstname='" + firstname + '\'' +
                ", secondname='" + secondname + '\'' +
                ", form='" + form + '\'' +
                ", mark=" + mark +
                ", present=" + present +
                ", show_date=" + show_date +
                ", subject='" + subject + '\'' +
                ", topic='" + topic + '\'' +
                ", work='" + work + '\'' +
                ", comment='" + comment + '\'' +
                ", login='" + login + '\'' +
                '}';
    }
}
