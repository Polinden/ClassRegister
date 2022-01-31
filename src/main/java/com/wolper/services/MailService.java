package com.wolper.services;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;


@Service
public class MailService {

    Logger logger = LoggerFactory.getLogger(MailService.class);

    @Autowired
    public JavaMailSender emailSender;

    @Async
    public void sendMessage(String to, String name, String form, boolean prepod) {
        try {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject("Восстановление пароля");
        StringBuilder sb=new StringBuilder();
        sb.append("Уважаемый ").append(name).append("!\n")
                .append(prepod?"":form+" класс!")
                .append("\n\n\n")
                .append("Для восстановления пароля просто ответьте на данное письмо, ")
                .append("указав желаемый пароль, и сообщите свой телефон! ")
                .append("\n")
                .append("Пароль должен быть криптостойким и известным только Вам!")
                .append("\n")
                .append("Администратор свяжется с Вами и лично сообщит о смене пароля!")
                .append("\n\n\n")
                .append("Хорошего Вам дня,\n")
                .append("Ваш классный журнал!");
        message.setText(sb.toString());
        emailSender.send(message);
        } catch (Exception ex) {
            logger.error("Оибка отправки почты по восстановлению пароля: "+ex.getMessage());
        }
    }
}

