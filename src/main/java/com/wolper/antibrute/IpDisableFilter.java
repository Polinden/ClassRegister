package com.wolper.antibrute;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.LockedException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;


public class IpDisableFilter implements Filter {


    Logger logger = LoggerFactory.getLogger(IpDisableFilter.class);
    @Autowired LoginAttemptService loginAttemptService;


    @Override
    public void doFilter(ServletRequest req, ServletResponse res,
                         FilterChain chain) throws IOException, ServletException {

        String address = req.getRemoteAddr();

        //block attempts to guess the password ...
        if (loginAttemptService.isBlocked(address)) {
            logger.info("Заблокирован за более 7 попыток подобрать пароль " + address);
            throw new LockedException("Вы заподозрены в подборе пароля! Ваш IP заблокирован на 24 часа! Обратитесь к администратору!");
        }

        //... or go on processing
        chain.doFilter(req, res);
    }


    public static String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme() + "://";
        String serverName = request.getServerName();
        String serverPort = (request.getServerPort() == 80) ? "" : ":" + request.getServerPort();
        String contextPath = request.getContextPath();
        return scheme + serverName + serverPort + contextPath;
    }


    @Override
    public void init(FilterConfig arg) throws ServletException {/**  empty **/}

    @Override
    public void destroy() {/**  empty **/}

}