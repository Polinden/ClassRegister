package com.wolper.antibrute;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.security.authentication.event.AuthenticationFailureBadCredentialsEvent;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;




@Component
public class AuthenticationFailureListener
        implements ApplicationListener<AuthenticationFailureBadCredentialsEvent> {


    @Autowired LoginAttemptService loginAttemptService;
    Logger logger = LoggerFactory.getLogger(AuthenticationFailureListener.class);


    public void onApplicationEvent(AuthenticationFailureBadCredentialsEvent e) {
        WebAuthenticationDetails auth = (WebAuthenticationDetails)
                e.getAuthentication().getDetails();
        String address = auth.getRemoteAddress();

        loginAttemptService.loginFailed(address);
        logger.info("Неверно ввел пароль "+auth.getRemoteAddress());
    }
}