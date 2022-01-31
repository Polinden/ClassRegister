package com.wolper.domain;


import java.text.SimpleDateFormat;

public class TopicSortedJournal {
    private String topic;
    private String subject;
    private int mark;
    private String date;
    private String work;
    private String comment;
    private String login;
    private boolean show_date;
    private boolean present;

    public String getTopic() {
        return topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public int getMark() {
        return mark;
    }

    public void setMark(int mark) {
        this.mark = mark;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
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

    public boolean isShow_date() {return show_date;}

    public void setShow_date(boolean show_date) {this.show_date = show_date;}

    public boolean isPresent() {return present;}

    public void setPresent(boolean present) {this.present = present;}

    public static TopicSortedJournal adapter(JournalEntity je){
        TopicSortedJournal topicSortedJournal = new TopicSortedJournal();
        topicSortedJournal.topic=je.getTopic();
        topicSortedJournal.work=je.getWork();
        topicSortedJournal.subject=je.getSubject();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy");
        topicSortedJournal.date=simpleDateFormat.format(je.getDate().getTime());
        topicSortedJournal.comment=je.getComment();
        topicSortedJournal.mark=je.getMark();
        topicSortedJournal.login=je.getStudent().getLogin();
        topicSortedJournal.show_date=je.isShow_date();
        topicSortedJournal.present=je.isPresent();
        return topicSortedJournal;
    }
}
