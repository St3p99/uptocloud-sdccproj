package unical.dimes.uptocloud;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import unical.dimes.uptocloud.configs.AzureSearchConfig;

@Component
public class Runner implements CommandLineRunner {
    private final AzureSearchConfig azureSearchConfig;

    @Autowired
    public Runner(AzureSearchConfig azureSearchConfig) {

        this.azureSearchConfig = azureSearchConfig;
    }

    @Override
    public void run(String... args){
        azureSearchConfig.configure();

    }
}
