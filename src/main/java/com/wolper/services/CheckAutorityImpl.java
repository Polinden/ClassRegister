package com.wolper.services;


import org.springframework.security.access.method.P;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Service;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;



//checking permissions
@Service
public class CheckAutorityImpl implements CheckAutority {

    @Override
    @PreAuthorize("hasAnyAuthority('prepod','admin') and #name == authentication.name")
    public boolean chechPrepod(@P(value = "name") String name){
        return true;
    }

    @Override
    @PreAuthorize("hasAnyAuthority('prepod','admin', 'stud')")
    public boolean chechPrepodAndStud(@P(value = "name") String name){return true;}

    @Override
    @PreAuthorize("#name == authentication.name")
    public boolean chechName(@P(value = "name") String name){return true;}



    public boolean checkRole(String role) {
        SecurityContext context = SecurityContextHolder.getContext();
        if (context == null)
            return false;

        Authentication authentication = context.getAuthentication();
        if (authentication == null)
            return false;

        for (GrantedAuthority auth : authentication.getAuthorities()) {
           if (auth.getAuthority().toString().equals(role)) {
               return true;
           }
        }

        return false;
    }

}
