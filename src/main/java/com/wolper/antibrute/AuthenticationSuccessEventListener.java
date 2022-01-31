package com.wolper.antibrute;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationListener;
import org.springframework.security.authentication.event.AuthenticationSuccessEvent;
import org.springframework.security.web.authentication.WebAuthenticationDetails;
import org.springframework.stereotype.Component;




@Component
public class AuthenticationSuccessEventListener
        implements ApplicationListener<AuthenticationSuccessEvent> {


    @Autowired LoginAttemptService loginAttemptService;
    Logger logger = LoggerFactory.getLogger(AuthenticationSuccessEventListener.class);

    public void onApplicationEvent(AuthenticationSuccessEvent e) {
        WebAuthenticationDetails auth = (WebAuthenticationDetails)
                e.getAuthentication().getDetails();
        String address = auth.getRemoteAddress();

        loginAttemptService.loginSucceeded(address);
        logger.info("Успешно вошел "+address+" по мени "+e.getAuthentication().getName());
    }
}