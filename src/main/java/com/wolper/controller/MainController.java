package com.wolper.controller;


import com.lowagie.text.DocumentException;
import com.wolper.services.CapchaService;
import com.wolper.services.CaptchaException;
import com.wolper.services.CheckAutority;
import com.wolper.services.MailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;


@Controller
public class MainController {


    @Autowired
    CheckAutority checkAutority;

    @Autowired
    CapchaService capchaService;

    @Autowired
    MailService mailService;

    Logger logger = LoggerFactory.getLogger(MainController.class);



    //start and exit page
    @RequestMapping(value="/")
    public String statrPage(HttpSession session) {
        session.invalidate();
        return "redirect: /goout";
    }


    //prepod edit marks page
    @RequestMapping(value="/prepod/{name}/enter")
    public String enterPage(@PathVariable(value = "name") String name, HttpServletResponse res) {
        if (!checkAutority.chechPrepod(name)) throw new AccessDeniedException("Cheater!!!");
        res.setHeader("Cache-Control", "max-age=600, private");
        return "enter_marks";
    }


    //prepod select page
    @RequestMapping(value="/prepod/{name}/select")
    public String selectPage(@PathVariable(value = "name") String name, HttpServletResponse res) {
        if (!checkAutority.chechPrepod(name))  throw new AccessDeniedException("Cheater!!!");
        res.setHeader("Cache-Control", "max-age=600, private");
        return "select";
    }


    //student page
    @RequestMapping(value="/stud/{name}/show")
    public String showPage(@PathVariable(value = "name") String name, HttpServletResponse res) {
        if (!checkAutority.chechPrepodAndStud(name))  return "/goout";
	if (checkAutority.checkRole("stud")) if (!checkAutority.chechName(name))  throw new AccessDeniedException("Cheater!!!");
        res.setHeader("Cache-Control", "max-age=600, private");
        return "stud_status";
    }


    //pdf page
    @RequestMapping(value="/prepod/{name}/pdf/{form}/{subj}", produces = "application/pdf;charset=UTF-8")
    public String showPdf(@PathVariable(value = "name") String name, @PathVariable(value = "form") String form, @PathVariable(value = "subj") String subj, Model model, HttpServletRequest request, HttpServletResponse res) {
        if (!checkAutority.chechPrepod(name)) throw new AccessDeniedException("Cheater!!!");
        Map<String,String> pdfData = new HashMap();
        pdfData.put("form",form);
        pdfData.put("subj",subj);
        pdfData.put("context",getHOSTandURIpartUntill(request, "/pdf/"));
        model.addAttribute("pdfData",pdfData);
        res.setHeader("Cache-Control", "no-store");
        return "pdfYearReportView";
    }


    //pass recovery
    @RequestMapping(value="/public/recoverypass", method = RequestMethod.POST)
    public String passrecovery(@RequestParam(value="mail") String to, @RequestParam(value="name") String name,
                               @RequestParam(value="form") String form,
                               @RequestParam(value="prepod", required = false) Boolean prepod,
                               @RequestParam(name="g-recaptcha-response") String recaptchaResponse,
                               HttpServletRequest request) {
        if (capchaService.verifyRecaptcha(request.getRemoteAddr(), recaptchaResponse)) {
            mailService.sendMessage(to, name, form, prepod!=null?prepod:false);
        }
        else throw new CaptchaException();
        return "redirect: ../goout";
    }





    //Security exeption handler
    @ExceptionHandler(value = AccessDeniedException.class) String handlerSecError(HttpServletRequest request) {
        logger.info("Злодейское проникновение! С IP="+ request.getRemoteAddr());
        return "secur_error";
    }

    //handle errors at parsing pdf response
    @ExceptionHandler(value = DocumentException.class) String handlerPdfError(DocumentException ex, HttpServletRequest request) {
        logger.info("Помилка підготовки звіту в форматі PDF! "+ex.getMessage()+ex.getCause());
        return "report_error";
    }

    //handle captcha errors
    @ExceptionHandler(value = CaptchaException.class) String handlerPdfError(CaptchaException ex, HttpServletRequest request) {
        return "captcha_error";
    }


    //helper for taking away url parts
    public String getHOSTandURIpartUntill(HttpServletRequest request, String border){
        StringBuffer serverURI=request.getRequestURL();
        int ind=serverURI.indexOf(border);
        String result =serverURI.substring(0, ind);
        return result;
    }
}
