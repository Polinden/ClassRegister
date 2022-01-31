package com.wolper.config;


import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.Ordered;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.web.servlet.ViewResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.web.servlet.view.BeanNameViewResolver;
import org.springframework.web.servlet.view.InternalResourceViewResolver;
import org.springframework.web.servlet.view.JstlView;
import java.nio.charset.Charset;




@EnableWebMvc
@Configuration
@ComponentScan(basePackages = { "com.wolper.controller" })
@PropertySource("classpath:config.properties")
@EnableAsync



public class WebConfig extends WebMvcConfigurerAdapter {


    //static resource handler
    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/public/**").addResourceLocations("/WEB-INF/public/");
        registry.addResourceHandler("/private/**").addResourceLocations("/WEB-INF/private/");
    }



    //BeanName resolver
    @Bean
    public ViewResolver beanNameViewResolver() {
        BeanNameViewResolver bean = new BeanNameViewResolver();
        bean.setOrder(0);
        return bean;
    }


    //jsp resolver
    @Bean
    public ViewResolver internalResourceViewResolver() {
        InternalResourceViewResolver bean = new InternalResourceViewResolver();
        bean.setViewClass(JstlView.class);
        bean.setPrefix("/WEB-INF/private/");
        bean.setSuffix(".jsp");
        bean.setOrder(1);
        return bean;
    }


    //JSON converter
    @Bean
    public MappingJackson2HttpMessageConverter converter() {
        MappingJackson2HttpMessageConverter m= new MappingJackson2HttpMessageConverter();
        m.setDefaultCharset(Charset.forName("UTF-8"));
        return m;
    }

}