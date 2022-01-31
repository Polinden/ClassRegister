package com.wolper.services;


import com.wolper.controller.RestMainController;
import com.wolper.domain.JournalList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import javax.annotation.PostConstruct;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.util.Arrays;
import java.util.Calendar;
import java.util.TimeZone;




//validator for journal page
@Component
public class DateConverterAndValidator {


    Logger logger = LoggerFactory.getLogger(RestMainController.class);

    //strings from property file
    String timeZoneGYI;


    @Autowired
    Environment env;


    //for tests
    public boolean weAreTesting=false;


    //settings for GYI service
    @PostConstruct
    public void settingsForGUIService(){
        timeZoneGYI = env.getProperty("timezone");
    }





    public void validate(JournalList[] jls) {
        boolean pass=true;
        for (JournalList jl : jls) {
            if (jl.getMark() < 0 || jl.getMark() > 12) pass= false;
            if (jl.getTopic() == null || jl.getTopic().isEmpty()) pass=  false;
            if (jl.getFirstname() == null || jl.getFirstname().isEmpty()) pass=  false;
            if (jl.getSubject() == null || jl.getSubject().isEmpty()) pass=  false;
            if (!pass) throw new MyConstrainException("Попытка  записи в журнал данных с ошибками. Нарушитель - ", jl.toString());
        }

    }


    //date dalidator
    public void validateDateRange(Calendar date) {

        //new time API
        ZonedDateTime z = ZonedDateTime.now(ZoneId.of(timeZoneGYI));

        //get today (free of time)
        Calendar today = Calendar.getInstance();
        today.set(z.getYear(), z.getMonthValue()-1, z.getDayOfMonth(), 0,0,0);

        //prerequisites
        final int MAX_MONTH=4;     //until May
        final int MIN_MONTH=7;     //from August
        final int SPECIAL_MONTH=7; //August for special report marks only

        // /days for specific event - summury marks
        int[] specialDates= {26,27,28,29,30,31};
        int currentDate= date.get(Calendar.DATE);
        int currentMonth= date.get(Calendar.MONTH);
        int currentYear= date.get(Calendar.YEAR);
        boolean accept = false;

        //in the range of dates allowed for editing:
        //first semester of the current year
        if ((today.get(Calendar.YEAR)==currentYear) && ((currentMonth>=MIN_MONTH)) && (today.get(Calendar.MONTH)>=MIN_MONTH)) accept=true;
        //second semester of the current year
        if ((today.get(Calendar.YEAR)==currentYear) && (currentMonth<=MAX_MONTH) && (today.get(Calendar.MONTH)<=MIN_MONTH)) accept=true;
        //first semester of the previous year but in the same school year
        if (((today.get(Calendar.YEAR)-1)==currentYear) && (currentMonth>=MIN_MONTH) && (today.get(Calendar.MONTH)<=MIN_MONTH)) accept=true;

        //but in case of specific month - only dates for summary marks
        if (currentMonth==SPECIAL_MONTH)
            if (Arrays.binarySearch(specialDates, currentDate)<0) accept=false;

        //and in any case not latter then today
        ///... we should disable this check for testing
        if (!weAreTesting)
            if ((date.getTime().getTime()-today.getTime().getTime())>60000) accept=false;

        if (!accept) throw new MyConstrainException("Обращения записи в бд за пределами разрешенных дат. Нарушитель - ", ""+currentDate+'-'+currentMonth+'-'+currentYear);
    }





    //calendar from string convertor
    public Calendar creatCalendar(String date, boolean forWriteData) {

        date=date.trim();
        String[] datestring = date.split("-");
        Calendar dayToWrite = Calendar.getInstance();

        //new time API
        ZonedDateTime z = ZonedDateTime.now(ZoneId.of(timeZoneGYI));

        //get today (free of time)
        Calendar today = Calendar.getInstance();
        today.set(z.getYear(), z.getMonthValue()-1, z.getDayOfMonth(), 0,0,0);


        //parse
        try {
            dayToWrite.set(Integer.parseInt(datestring[2]), Integer.parseInt(datestring[1]) - 1, Integer.parseInt(datestring[0]), 0,0,0);
            //validate for situation if we are going to write to journal
            if (forWriteData) validateDateRange(dayToWrite);
        } catch (NumberFormatException ex) {dayToWrite=null;}

        if (dayToWrite==null) throw new MyConstrainException("Дата передана в неверном формате. Нарушитель - ", date);
        return dayToWrite;
    }


    //get report year
    public Calendar getReportYear() {

        final int TILL_SEPTEMBER = 8;

        //new time API
        ZonedDateTime z = ZonedDateTime.now(ZoneId.of(timeZoneGYI));

        //get today (free of time)
        Calendar today = Calendar.getInstance();
        today.set(z.getYear(), z.getMonthValue()-1, z.getDayOfMonth(), 0,0,0);
        int currentMonth= today.get(Calendar.MONTH);
        int currentYear= today.get(Calendar.YEAR);


        //if we are in the next school year to decrease
        if (currentMonth<TILL_SEPTEMBER) currentYear--;

        //report period starts from 26.08 of report year (from 26.08 to 1.09 - summury marks are placed)
        today.set(currentYear, 7, 25, 0,0,0);
        return today;
    }
}

