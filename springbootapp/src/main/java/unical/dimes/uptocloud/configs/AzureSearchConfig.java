package unical.dimes.uptocloud.configs;


import com.azure.core.credential.AzureKeyCredential;
import com.azure.core.http.rest.Response;
import com.azure.core.util.Context;
import com.azure.search.documents.SearchAsyncClient;
import com.azure.search.documents.SearchClient;
import com.azure.search.documents.SearchClientBuilder;
import com.azure.search.documents.indexes.*;
import com.azure.search.documents.indexes.models.SearchField;
import com.azure.search.documents.indexes.models.SearchFieldDataType;
import com.azure.search.documents.indexes.models.SearchIndex;
import com.azure.search.documents.indexes.models.SearchSuggester;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.List;

@Configuration
public class AzureSearchConfig {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    @Value("${azure.search.serviceName}")
    private String serviceName;
    @Value("${azure.search.serviceAdminKey}")
    private String adminKey;
    @Value("${azure.search.indexName}")
    private String indexName;

    public static final List<String> searchableFieldNames =
            List.of("tags", "fileType", "description", "filename", "metadata_storage_file_extension");


    @Bean
    public SearchIndexClient getSearchIndexClient(){
        return new SearchIndexClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .buildClient();
    }

    @Bean
    public SearchIndexAsyncClient getSearchIndexAsyncClient(){
        return new SearchIndexClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .buildAsyncClient();
    }

    @Bean
    public SearchIndexerClient getSearchIndexerClient(){
        return new SearchIndexerClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .buildClient();
    }

    @Bean
    public SearchIndexerAsyncClient getSearchIndexerAsyncClient(){
        return new SearchIndexerClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .buildAsyncClient();
    }
    @Bean
    public SearchClient getSearchClient(){
        return new SearchClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .indexName(indexName)
                .buildClient();
    }

    @Bean
    public SearchAsyncClient getSearchAsyncClient(){
        return new SearchClientBuilder()
                .endpoint("https://"+serviceName+".search.windows.net")
                .credential(new AzureKeyCredential(adminKey))
                .indexName(indexName)
                .buildAsyncClient();
    }

    public void configure(){
        createSearchIndex();
    }

    @Bean
    public SearchIndex createSearchIndex(){
        SearchIndexClient searchIndexClient = getSearchIndexClient();
        Response<SearchIndex> response;
        try{
            response = searchIndexClient.getIndexWithResponse(indexName, Context.NONE);
        }catch (Exception e){
            return searchIndexClient.createIndex(
                new SearchIndex(
                    indexName,
                    Stream.of(
                            new SearchField("id", SearchFieldDataType.STRING).setKey(true)
                                    .setFilterable(true).setSearchable(true),
                            new SearchField("content", SearchFieldDataType.STRING)
                                    .setFilterable(false).setFacetable(false).setSortable(false)
                                    .setSearchable(true),
                            new SearchField("tags", SearchFieldDataType.collection(SearchFieldDataType.STRING))
                                    .setFilterable(true).setSearchable(true).setFacetable(true),
                            new SearchField("fileType", SearchFieldDataType.STRING)
                                    .setFilterable(true).setSearchable(true).setSortable(true).setFacetable(true),
                            new SearchField("description", SearchFieldDataType.STRING)
                                    .setFilterable(true).setSearchable(true),
                            new SearchField("filename", SearchFieldDataType.STRING)
                                    .setFilterable(true).setSearchable(true).setSortable(true),
                            new SearchField("metadata_storage_size", SearchFieldDataType.INT64)
                                    .setFilterable(true).setSortable(true),
                            new SearchField("metadata_storage_last_modified", SearchFieldDataType.DATE_TIME_OFFSET)
                                    .setFilterable(true).setSortable(true),
                            new SearchField("metadata_storage_file_extension", SearchFieldDataType.STRING)
                                    .setFilterable(true).setSearchable(true).setSortable(true).setFacetable(true)
                    ).collect(Collectors.toList())
                ).setSuggesters(new SearchSuggester("sg", searchableFieldNames)));
        }
        logger.info("SearchIndex already exists");
        return response.getValue();
    }

}
