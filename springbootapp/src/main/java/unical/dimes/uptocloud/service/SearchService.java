package unical.dimes.uptocloud.service;

import com.azure.core.exception.HttpResponseException;
import com.azure.core.util.Context;
import com.azure.search.documents.SearchAsyncClient;
import com.azure.search.documents.SearchClient;
import com.azure.search.documents.SearchDocument;
import com.azure.search.documents.indexes.SearchIndexClient;
import com.azure.search.documents.indexes.SearchIndexerClient;
import com.azure.search.documents.indexes.SearchIndexerDataSources;
import com.azure.search.documents.indexes.models.FieldMapping;
import com.azure.search.documents.indexes.models.FieldMappingFunction;
import com.azure.search.documents.indexes.models.SearchIndexer;
import com.azure.search.documents.indexes.models.SearchIndexerDataSourceConnection;
import com.azure.search.documents.models.AutocompleteOptions;
import com.azure.search.documents.models.QueryType;
import com.azure.search.documents.models.SearchOptions;
import com.azure.search.documents.util.AutocompletePagedIterable;
import com.azure.search.documents.util.SearchPagedFlux;
import com.azure.search.documents.util.SearchPagedIterable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import unical.dimes.uptocloud.configs.AzureSearchConfig;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.Tag;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;

import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

@Service
public class SearchService {
    private final SearchIndexClient searchIndexClient;
    private final SearchClient searchClient;
    private final SearchIndexerClient searchIndexerClient;
    private final UserService userService;
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    @Value("${azure.search.serviceName}")
    private String serviceName;
    @Value("${azure.search.serviceAdminKey}")
    private String adminKey;
    @Value("${azure.storage.connString}")
    private String blobConnectStr;

    private final String indexName;
    @Value("${azure.search.datasourceBaseName}")
    private String datasourceBaseName;
    @Value("${azure.search.indexerBaseName}")
    private String indexerBaseName;
    private final SearchAsyncClient searchAsyncClient;
    private final DocumentService documentService;

    @Autowired
    public SearchService(@Value("${azure.search.indexName}") String indexName, SearchIndexClient searchIndexClient, SearchClient searchClient, SearchIndexerClient searchIndexerClient, UserService userService, SearchAsyncClient searchAsyncClient,DocumentService documentService) {
        this.indexName = indexName;
        this.searchIndexClient = searchIndexClient;
        this.searchIndexerClient = searchIndexerClient;
        this.searchClient = searchClient;
        this.userService = userService;
        this.searchAsyncClient = searchAsyncClient;
        this.documentService = documentService;
    }

    private String getIDAccessibleDocuments(User u) {
        List<Document> documents = u.getDocumentsOwned();
        documents.addAll(u.getDocumentsReadable());
        Iterator<Document> iterator = documents.iterator();
        StringBuilder sb = new StringBuilder();
        if (iterator.hasNext()) sb.append("'").append(iterator.next().getId());
        else return null;
        while (true) {
            if (!iterator.hasNext()) {
                sb.append("'");
                break;
            }
            sb.append(",").append(iterator.next().getId());
        }

        return sb.toString();
    }

    private String getTagsFormatted(List<String> tags) {
        Iterator<String> iterator = tags.iterator();
        StringBuilder sb = new StringBuilder();
        if (iterator.hasNext()) sb.append("'").append(iterator.next());
        while (true) {
            if (!iterator.hasNext()) {
                sb.append("'");
                break;
            }
            sb.append(",").append(iterator.next());
        }

        return sb.toString();
    }

    private List<String> getSearchField(boolean searchInContent) {
        List<String> searchFields;
        if (searchInContent) {
            searchFields = new ArrayList<>(AzureSearchConfig.searchableFieldNames);
            searchFields.add("content");
        } else {
            searchFields = AzureSearchConfig.searchableFieldNames;
        }
        return searchFields;
    }


    private String inputRegexContains(String input){
        StringBuilder sb = new StringBuilder();
        for (String s: input.split(" ")) {
            sb.append("/.*").append(s).append(".*/");
        }
        return sb.toString();
    }

    private String inputFuzzy(String input, int distance){
        StringBuilder sb = new StringBuilder();
        for (String s: input.split(" ")) {
            sb.append(s).append("~").append(distance).append(" ");
        }
        return sb.toString().trim();
    }

    @Transactional(readOnly = true)
    List<Long> processResult(SearchPagedFlux searchPagedFlux) {
        List<Long> ret = new LinkedList<>();
        new SearchPagedIterable(searchPagedFlux).forEach((result) -> {
                    SearchDocument searchDocument = result.getDocument(SearchDocument.class);
                    Long docID = Long.parseLong((String) searchDocument.get("id"));
                    ret.add(docID);
                }
        );
        return ret;
    }

    @Transactional(readOnly = true)
    public List<Document> searchAnyFieldsContains(String userID, boolean searchInContent, String text) throws ResourceNotFoundException {
        User user;
        try {
            user = userService.getById(userID);
        } catch (ResourceNotFoundException e) {
            logger.warning(e.toString());
            throw e;
        }

        String ids = getIDAccessibleDocuments(user);
        if(ids == null) return new LinkedList<>();


        SearchOptions options = new SearchOptions()
                .setFilter(String.format("search.in(id, %s)", ids))
                .setQueryType(QueryType.FULL)
                .setOrderBy("search.score()")
                .setSearchFields(getSearchField(searchInContent).toArray(new String[0]));

        SearchPagedFlux searchPagedFlux = searchAsyncClient.search(
                inputFuzzy(text,1)+inputRegexContains(text),
                options);

        searchPagedFlux.getTotalCount().subscribe(
                count -> System.out.printf("There are around %d results.", count)
        );

        List<Document> ret = new LinkedList<>();
        for (Long docID: processResult(searchPagedFlux)) {
            ret.add(documentService.getById(docID));
        }
        return ret;
    }
    public List<Document> searchByTags(String userID, List<String> tags) throws ResourceNotFoundException {
        User user;
        try {
            user = userService.getById(userID);
        } catch (ResourceNotFoundException e) {
            logger.warning(e.toString());
            throw e;
        }

        String ids = getIDAccessibleDocuments(user);
        if(ids == null) return new LinkedList<>();

        SearchOptions options = new SearchOptions()
                .setFilter(String.format("search.in(id, %s)", ids))
                .setQueryType(QueryType.FULL)
                .setSearchFields("tags");

        Iterator<String> iterator = tags.iterator();
        StringBuilder sb = new StringBuilder();
        while (iterator.hasNext()) {
            String tag = iterator.next();
            sb.append(tag);
            if (iterator.hasNext()) {
                sb.append("||");
            }
        }

        SearchPagedFlux searchPagedFlux = searchAsyncClient.search(sb.toString(), options);

        searchPagedFlux.getTotalCount().subscribe(
                count -> logger.info(String.format("There are around %d results.", count))
        );

        List<Document> ret = new LinkedList<>();
        for (Long docID: processResult(searchPagedFlux)) {
            ret.add(documentService.getById(docID));
        }
        return ret;
    }

    public List<Document> searchByAnyFieldsContainsAndTags(String userID, boolean searchInContent, String text, List<String> tags) throws ResourceNotFoundException {
        User user;
        try {
            user = userService.getById(userID);
        } catch (ResourceNotFoundException e) {
            logger.warning(e.toString());
            throw e;
        }

        String ids = getIDAccessibleDocuments(user);
        if(ids == null) return new LinkedList<>();

        String filter = String.format("search.in(id, %s)", ids)
                        + " and "+String.format("tags/any(t: search.in(t, %s))", getTagsFormatted(tags));

        SearchOptions options = new SearchOptions()
                .setFilter(filter)
                .setQueryType(QueryType.FULL)
                .setOrderBy("search.score()")
                .setSearchFields(getSearchField(searchInContent).toArray(new String[0]));

        logger.info("searching...");
        SearchPagedFlux searchPagedFlux = searchAsyncClient.search(
                inputFuzzy(text,1)+inputRegexContains(text),
                options);

        searchPagedFlux.getTotalCount().subscribe(
                count -> logger.info(String.format("There are around %d results.", count))
        );

        List<Document> ret = new LinkedList<>();
        for (Long docID: processResult(searchPagedFlux)) {
            System.out.println(docID);
            try {
                ret.add(documentService.getById(docID));
            } catch (ResourceNotFoundException e) {
                logger.warning(e.toString());
                throw e;
            }
        }
        return ret;
    }

    public List<String> autocomplete(String userID, String text) throws ResourceNotFoundException{
        User user;
        try {
            user = userService.getById(userID);
        } catch (ResourceNotFoundException e) {
            logger.warning(e.toString());
            throw e;
        }

        String ids = getIDAccessibleDocuments(user);
        if(ids == null) return new LinkedList<>();

        AutocompleteOptions options = new AutocompleteOptions()
                .setFilter(String.format("search.in(id, %s)", ids))
                .setSearchFields(getSearchField(false).toArray(new String[0]));

         AutocompletePagedIterable autocompletePagedIterable = searchClient.autocomplete(
                 inputFuzzy(text,1)+inputRegexContains(text),
                 "sg", options, Context.NONE);

        List<String> ret = new LinkedList<>();
        autocompletePagedIterable.forEach((result) -> ret.add(result.getText()));

        return ret;
    }

    public Set<Tag> getTagSuggestions(String userID) throws ResourceNotFoundException {
        User user;
        try {
            user = userService.getById(userID);
        } catch (ResourceNotFoundException e) {
            logger.warning(e.toString());
            throw e;
        }

        Set<Tag> ret = new HashSet<>();

        for (Document d: user.getDocumentsOwned()) {
            ret.addAll(d.getMetadata().getTags());
        }
        for (Document d: user.getDocumentsReadable()) {
            ret.addAll(d.getMetadata().getTags());
        }
        return ret;
    }
    public SearchIndexer getOrCreateSearchIndexer(String containerName) {
        SearchIndexer indexer = null;
        try {
            indexer = searchIndexerClient.getIndexer(indexerBaseName + containerName);
        } catch (Exception e) {
            indexer = searchIndexerClient.createIndexer(
                    new SearchIndexer(
                            indexerBaseName + containerName, datasourceBaseName + containerName, indexName
                    )).setFieldMappings(
                    new FieldMapping("tags").setTargetFieldName("tags").setMappingFunction(
                            new FieldMappingFunction("jsonArrayToStringCollection"))
            );

        } finally {
            return indexer;
        }
    }

    public SearchIndexerDataSourceConnection getOrCreateDataSourceConnection(String containerName) {
        SearchIndexerDataSourceConnection datasource = null;
        try {
            datasource = searchIndexerClient.getDataSourceConnection(datasourceBaseName + containerName);
        } catch (Exception e) {
            datasource = searchIndexerClient.createDataSourceConnection(
                    SearchIndexerDataSources.createFromAzureBlobStorage(datasourceBaseName + containerName, blobConnectStr, containerName));

        } finally {
            return datasource;
        }
    }

    public void deleteDatasourceConnection(String containerName) {
        try {
            searchIndexerClient.deleteDataSourceConnection(datasourceBaseName + containerName);
        } catch (Exception e) {
            return;
        }
    }

    public void deleteSearchIndexer(String containerName) {
        try {
            searchIndexerClient.deleteIndexer(indexerBaseName + containerName);
        } catch (Exception e) {
            return;
        }
    }

    public void runIndexer(String containerName) {
        SearchIndexer indexer = getOrCreateSearchIndexer(containerName);
        new RunIndexer(indexer).start();
    }




    private class RunIndexer extends Thread {

        private final static int MAX_ATTEMPTS = 10;
        private final SearchIndexer indexer;
        private int n = 0;

        public RunIndexer(SearchIndexer indexer) {
            this.indexer = indexer;
        }

        @Override
        public void run() {
            try {
                while (n < MAX_ATTEMPTS) {
                    try {
                        searchIndexerClient.runIndexer(indexer.getName());
                        return;
                    } catch (HttpResponseException e) {
                        logger.warning(e.getMessage());
                        n++;
                        TimeUnit.SECONDS.sleep(180L * n);
                        logger.warning("runIndexer ATTEMPTS=" + n + "");
                    }
                }
                throw new RuntimeException();
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
