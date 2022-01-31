package com.wolper.domain;



import org.hibernate.annotations.*;
import javax.persistence.*;
import javax.persistence.Entity;
import javax.persistence.OrderBy;
import javax.persistence.Table;
import java.util.Set;
import java.util.TreeSet;


@Entity
@Table(name="class", schema = "public", catalog = "fmh")



public class ClassEntity {

    private String classname;
    private Set<UsersEntity> students= new TreeSet();



    @Id
    @Column(name = "class_name", length = 8)
    public String getClassname() {
        return classname;
    }

    public void setClassname(String classname) {
        this.classname = classname;
    }



    //class list
    @ElementCollection
    @BatchSize(size = 10)
    @OrderBy(value = "firstName ASC")
    @CollectionTable(name="class_AND_students", joinColumns=@JoinColumn(name="class_name"))
    @Column(length=50, nullable = false)
    public Set<UsersEntity> getStudents() {
        return students;
    }

    public void setStudents(Set<UsersEntity> students) {
        this.students = students;
    }




    //hash and equal
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        ClassEntity that = (ClassEntity) o;

        return classname != null ? classname.equals(that.classname) : that.classname == null;

    }

    @Override
    public int hashCode() {
        return classname != null ? classname.hashCode() : 0;
    }
}
