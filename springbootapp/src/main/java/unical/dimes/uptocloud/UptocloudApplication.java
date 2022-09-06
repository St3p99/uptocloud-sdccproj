package unical.dimes.uptocloud;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.retry.annotation.EnableRetry;

import javax.annotation.PostConstruct;
import java.util.TimeZone;

@EnableRetry
@SpringBootApplication
@EntityScan(basePackages = {"unical.dimes.uptocloud.model"})  // scan JPA entities
public class UptocloudApplication {


    public static void main(String[] args) {
        SpringApplication.run(UptocloudApplication.class, args);

    }

    @PostConstruct
    public void init(){
        // Setting Spring Boot SetTimeZone
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
    }



}



