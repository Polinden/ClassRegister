package com.wolper.domain;


import java.util.HashSet;
import java.util.List;
import java.util.Set;



//auxiliary lightweight class for transfering concise data about prepod to frontend
public class SubjectClassLists {


    private String subject;
    private Set<String> classes;


    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public Set<String> getClasses() {
        return classes;
    }

    public void setClasses(Set<String> classes) {
        this.classes = classes;
    }



    public static Set<SubjectClassLists> listAdapter(List<PrepodEntity> pe){
        if (pe==null) return null;
        if (pe.isEmpty()) return null;
        Set<SubjectClassLists> subjectClassListses = new HashSet<>();
        for (PrepodEntity ppe : pe) {
            SubjectClassLists subjectClassLists = new SubjectClassLists();
            subjectClassLists.setSubject(ppe.getSubject());
            Set<String> cls = new HashSet<>();
            for (ClassEntity cl : ppe.getClasses()) {
                cls.add(cl.getClassname());
            }
            subjectClassLists.setClasses(cls);
            subjectClassListses.add(subjectClassLists);
        }
        return subjectClassListses;
    }

}
