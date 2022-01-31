package com.wolper.services;

import com.fasterxml.jackson.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import javax.annotation.PostConstruct;
import java.net.URI;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;


@PropertySource(value = "classpath:config.properties", encoding = "UTF-8")

@Service
public class CapchaService {

    @Autowired
    Environment env;

    private String recaptchaSecret;
    private String captchaURL;

    @PostConstruct
    public void init() {
        recaptchaSecret = env.getProperty("captcha.secret");
        captchaURL = env.getProperty("captcha.cite");
    }


    public boolean verifyRecaptcha(String ip, String recaptchaResponse) {

        try {

            RestTemplate restTemplate = new RestTemplate();
            URI verifyUri = URI.create(String.format(captchaURL, recaptchaSecret, recaptchaResponse, ip));
            restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());

            ReCaptchaResponse googleResponse = restTemplate.getForObject(verifyUri, ReCaptchaResponse.class);
            return (boolean) googleResponse.isSuccess();

        } catch (Exception ex) {throw new CaptchaException();}
    }


    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonIgnoreProperties(ignoreUnknown = true)
    @JsonPropertyOrder({
            "success",
            "challenge_ts",
            "hostname",
            "error-codes"
    })
    public static class ReCaptchaResponse {

        @JsonProperty("success")
        private boolean success;

        @JsonProperty("challenge_ts")
        private Date challengeTs;

        @JsonProperty("hostname")
        private String hostname;

        @JsonProperty("error-codes")
        private ErrorCode[] errorCodes;

        @JsonIgnore
        public boolean hasClientError() {
            ErrorCode[] errors = getErrorCodes();
            if(errors == null) {
                return false;
            }
            for(ErrorCode error : errors) {
                switch(error) {
                    case InvalidResponse:
                    case MissingResponse:
                        return true;
                }
            }
            return false;
        }

        static enum ErrorCode {
            MissingSecret,     InvalidSecret,
            MissingResponse,   InvalidResponse;

            private static Map<String, ErrorCode> errorsMap = new HashMap<>(4);

            static {
                errorsMap.put("missing-input-secret",   MissingSecret);
                errorsMap.put("invalid-input-secret",   InvalidSecret);
                errorsMap.put("missing-input-response", MissingResponse);
                errorsMap.put("invalid-input-response", InvalidResponse);
            }

            @JsonCreator
            public static ErrorCode forValue(String value) {
                return errorsMap.get(value.toLowerCase());
            }
        }

        public boolean isSuccess() { return success; }

        public void setSuccess(boolean success) { this.success = success; }

        public Date getChallengeTs() { return challengeTs; }

        public void setChallengeTs(Date challengeTs) { this.challengeTs = challengeTs; }

        public String getHostname() { return hostname; }

        public void setHostname(String hostname) { this.hostname = hostname; }

        public ErrorCode[] getErrorCodes() { return errorCodes; }

        public void setErrorCodes(ErrorCode[] errorCodes) { this.errorCodes = errorCodes; }
    }


}
