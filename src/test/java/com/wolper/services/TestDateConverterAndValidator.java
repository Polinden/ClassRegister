package com.wolper.services;


//!!!!
//  Attention!!!!!!!!!!!!!!!
//!!!!
//  this test is designed for launching when the system clock is set up to 1.01.2017...30.07.2017
//!!!!




import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.TimeZone;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;


@RunWith(Parameterized.class)
public class TestDateConverterAndValidator {




    DateConverterAndValidator dateConverterAndValidator;
    static SimpleDateFormat simpleDateFormat  = new SimpleDateFormat("dd-MM-YYYY");


    @Before
    public void init(){
        dateConverterAndValidator = new DateConverterAndValidator();
        dateConverterAndValidator.timeZoneGYI= "Europe/Kiev";
        dateConverterAndValidator.weAreTesting=true;
    }





    //parameters are List of bad dates

    Calendar cycleTestDate;

    @Parameterized.Parameters
    public static Collection datesFromSource() {
        return generate4FailTest();
    }

    public TestDateConverterAndValidator(Calendar cycleTestDate) {
        this.cycleTestDate=cycleTestDate;
    }





    //TESTS!!!!

    //test for good dates
    @Test
    public void goodDatesValidatorTest(){
            for (Calendar calendar : generate4Test()) dateConverterAndValidator.validateDateRange(calendar);
    }


    //test for bad dates in cycle
    @Test(expected = MyConstrainException.class)
        public void badDatesValidatorTest() {
            //cycleTestDate.set(2017, 0, 5, 0,0,0); // for testing - if uncomment, this test is to fail
            dateConverterAndValidator.validateDateRange(cycleTestDate);
    }


    //test date converter
    @Test
    public void convertDateTest(){
        String myDate = simpleDateFormat.format(cycleTestDate.getTime());
        long test1=cycleTestDate.getTime().getTime();
        long test2=dateConverterAndValidator.creatCalendar(myDate, false).getTime().getTime();
        long delta = Math.abs(test1-test2);
        //as we comparing dates in milliseconds
        //we allowing for 10 seconds between input date and formated date
        assertTrue(delta<10_000);
    }







    //HELPERS!!!!

    public ArrayList<Calendar> generate4Test(){

        ArrayList<Calendar> calendars = new ArrayList();

        //!!!!
        //this test is designed for launching when the system clock is set up to 1.01.2017-30.07.2017
        //!!!!

        Calendar testedDate;

        //1.09.2016 FIRST TEST
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)-1, 8, 1, 0,0,0);
        calendars.add(testedDate);
        assertEquals("01-09-2016", simpleDateFormat.format(testedDate.getTime()));

        //28.08.2016 SECOND TEST
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)-1, 7, 28, 0,0,0);
        calendars.add(testedDate);
        assertEquals("28-08-2016", simpleDateFormat.format(testedDate.getTime()));

        //30.05.2017 THIRD TEST
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR), 4, 30, 0,0,0);
        calendars.add(testedDate);
        assertEquals("30-05-2017", simpleDateFormat.format(testedDate.getTime()));

        return calendars;
    }






    public static ArrayList<Calendar> generate4FailTest(){

        ArrayList<Calendar> calendars = new ArrayList();


        //!!!!
        //this test is designed for launching when the system clock is set up to 1.01.2017-30.07.2017
        //!!!!


        Calendar testedDate;

        //30.07.2016
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)-1, 6, 30, 0,0,0);
        calendars.add(testedDate);
        assertEquals("30-07-2016", simpleDateFormat.format(testedDate.getTime()));

        //25.08.2016
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)-1, 7, 25, 0,0,0);
        calendars.add(testedDate);
        assertEquals("25-08-2016", simpleDateFormat.format(testedDate.getTime()));

        //1.06.2017
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR), 5, 1, 0,0,0);
        calendars.add(testedDate);
        assertEquals("01-06-2017", simpleDateFormat.format(testedDate.getTime()));

        //1.09.2015
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)-2, 8, 1, 0,0,0);
        calendars.add(testedDate);
        assertEquals("01-09-2015", simpleDateFormat.format(testedDate.getTime()));

        //1.03.2018
        testedDate= getCalendar4Test();
        testedDate.set(testedDate.get(Calendar.YEAR)+1, 2, 1, 0,0,0);
        calendars.add(testedDate);
        assertEquals("01-03-2018", simpleDateFormat.format(testedDate.getTime()));

        return calendars;
    }


    public static Calendar getCalendar4Test(){
        Calendar testedDate = Calendar.getInstance();
        testedDate.set(testedDate.get(Calendar.YEAR), testedDate.get(Calendar.MONTH), testedDate.get(Calendar.DATE), 0,0,0);
        testedDate.setTimeZone(TimeZone.getTimeZone("Europe/Kiev"));
        return testedDate;
    }

}