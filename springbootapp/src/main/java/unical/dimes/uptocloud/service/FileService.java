package unical.dimes.uptocloud.service;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.specialized.BlockBlobClient;
import jakarta.json.Json;
import jakarta.json.JsonArray;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import unical.dimes.uptocloud.model.*;
import unical.dimes.uptocloud.repository.DocumentMetadataRepository;
import unical.dimes.uptocloud.repository.DocumentRepository;
import unical.dimes.uptocloud.repository.TagRepository;
import unical.dimes.uptocloud.support.Utils;
import unical.dimes.uptocloud.support.exception.FileSizeExceededException;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import unical.dimes.uptocloud.support.exception.UnauthorizedUserException;
import unical.dimes.uptocloud.support.exception.UniqueKeyViolationException;


import java.io.*;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class FileService {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    private final BlobServiceClient blobServiceClient;
    private final DocumentRepository documentRepository;
    private final TagRepository tagRepository;
    private final DocumentService documentService;
    private final DocumentMetadataService documentMetadataService;
    private final UserService userService;
    private final DocumentMetadataRepository documentMetadataRepository;
    private final SearchService searchService;
    @Value("${max-file-size}")
    private long max_file_size;
    @Autowired
    public FileService(BlobServiceClient blobServiceClient, TagRepository tagRepository, DocumentRepository documentRepository, DocumentService documentService, DocumentMetadataService documentMetadataService, UserService userService, DocumentMetadataRepository documentMetadataRepository, SearchService searchService) {
        this.blobServiceClient = blobServiceClient;
        this.tagRepository = tagRepository;
        this.documentRepository = documentRepository;
        this.documentService = documentService;
        this.documentMetadataService = documentMetadataService;
        this.userService = userService;
        this.documentMetadataRepository = documentMetadataRepository;
        this.searchService = searchService;

    }

    @Transactional(propagation = Propagation.REQUIRED, rollbackFor = Exception.class)
    public Document uploadDocument(String userID, MultipartFile file)
            throws UniqueKeyViolationException, FileSizeExceededException,
                    ResourceNotFoundException, IOException {
        if(file.getSize() > FileUtils.ONE_MB*max_file_size)
            throw new FileSizeExceededException();
        User u = null;
        Document d = new Document();
        DocumentMetadata dm;
        String resourceUrl = null;
        boolean success = false;
        try {
            u = userService.getById(userID);
            if(documentRepository.existsByNameAndOwner(file.getOriginalFilename(), u))
                throw new UniqueKeyViolationException("");
            d.setOwner(u);
            d.setName( file.getOriginalFilename());
            documentRepository.save(d); // Save to generate docID

            // SET METADATA
            String mimeType = file.getContentType();
            dm = new DocumentMetadata(d);
            dm.setFileType(mimeType);
            dm.setFileSize(file.getSize());
            Map<String, String> blobMetadata = new HashMap<>();
            blobMetadata.put(MetadataCategory.FILE_NAME.toString(), Utils.removeSpecialChar(file.getOriginalFilename()));
            blobMetadata.put(MetadataCategory.FILE_TYPE.toString(), mimeType);
            blobMetadata.put(MetadataCategory.ID.toString(), d.getId().toString());

            documentMetadataRepository.save(dm);

            // upload file to azure blob storage
            resourceUrl = uploadToBlob(u, d, file, blobMetadata);
            d.setResourceUrl(resourceUrl);
            d = documentRepository.save(d);

            searchService.runIndexer(u.getContainerName()); // run indexer
            success = true;
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        } catch (IOException e) {
            logger.severe(e.toString());
            documentRepository.delete(d);
            throw e;
        } catch (Exception e){
            logger.severe(e.toString());
            throw e;
        }finally{
            if(!success && resourceUrl!=null) deleteFromBlob(u, d);
        }

        return d;
    }

    public void deleteDocument(String userID, Long docID) throws  ResourceNotFoundException, UnauthorizedUserException{
        User u = userService.getById(userID);
        Document d = documentService.getById(docID);

        if(!d.getOwner().equals(u)){
            logger.warning("User doesn't have permission to delete this document");
            throw new UnauthorizedUserException();
        }

        deleteFromBlob(u, d);
        searchService.runIndexer(u.getContainerName()); // run indexer
        documentRepository.delete(d);
    }

    public void deleteDocuments(String userID, List<Long> docsID) throws  ResourceNotFoundException, UnauthorizedUserException{
        User u = userService.getById(userID);
        List<Document> documents = new LinkedList<>();
        for (Long docID: docsID) {
            Document d = documentService.getById(docID);
            if(!d.getOwner().equals(u)){
                logger.warning("User doesn't have permission to delete this document");
                throw new UnauthorizedUserException();
            }
            documents.add(d);
        }
        for (Document d: documents) {
            deleteFromBlob(u, d);
            documentRepository.delete(d);
        }
        searchService.runIndexer(u.getContainerName()); // run indexer
    }

    private String uploadToBlob(User u, Document d, MultipartFile file, Map<String, String> metadata) throws IOException {
        BlockBlobClient blockBlobClient = getOrCreateContainerByOwner(u).getBlobClient(d.getId().toString()).getBlockBlobClient();
        blockBlobClient.upload(new BufferedInputStream(file.getInputStream()), file.getSize(), true);
        logger.log(Level.INFO, String.format("File %s uploaded in blob '%s'",  file.getOriginalFilename(), blockBlobClient.getBlobName()));
        blockBlobClient.setMetadata(metadata);
        return blockBlobClient.getBlobUrl();
    }

    private void deleteFromBlob(User u, Document d){
        BlockBlobClient blockBlobClient = getOrCreateContainerByOwner(u).getBlobClient(d.getId().toString()).getBlockBlobClient();
        blockBlobClient.delete();
    }

    public void setMetadata(String userID, Long docID, String filename,
                            String description, List<String> tagsName)
            throws IllegalArgumentException, ResourceNotFoundException, UnauthorizedUserException {
        User u;
        Document d;
        DocumentMetadata dm;
        Set<Tag> tags = new HashSet<>();
        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
            dm = documentMetadataService.getByDocument(d);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(u)){
            logger.warning("User doesn't have permission for this document to set metadata");
            throw new UnauthorizedUserException();
        }

        BlockBlobClient blockBlobClient = getOrCreateContainerByOwner(u).getBlobClient(d.getId().toString()).getBlockBlobClient();
        Map<String, String> blobMetadata = blockBlobClient.getProperties().getMetadata();

        if(filename!=null && !filename.isEmpty()){
            d.setName(filename);
            blobMetadata.put(MetadataCategory.FILE_NAME.toString(),  Utils.removeSpecialChar(filename));
        }

        if(description!=null && !description.isEmpty()){
            dm.setDescription(description.trim());
            blobMetadata.put(MetadataCategory.DESCRIPTION.toString(), Utils.removeSpecialChar(description));
        }else{
            dm.setDescription("");
            blobMetadata.remove(MetadataCategory.DESCRIPTION.toString());
        }

        if(tagsName!=null && !tagsName.isEmpty()){
            Tag t;
            for (String tagName: tagsName) {
                Optional<Tag> ot = tagRepository.findByName(tagName);
                if( ot.isPresent() ) t = ot.get();
                else{
                    t = new Tag(Utils.removeSpecialChar(tagName));
                    tagRepository.save(t);
                }
                tags.add(t);
            }
            dm.setTags(new LinkedList<>(tags));
            JsonArray jsonArray = Json.createArrayBuilder(tagsName).build();
            blobMetadata.put(MetadataCategory.TAGS.toString(),  jsonArray.toString());
        }else{
            dm.setTags(new LinkedList<>());
            blobMetadata.remove(MetadataCategory.TAGS.toString());
        }
        System.out.println(blobMetadata);
        blockBlobClient.setMetadata(blobMetadata);
        searchService.runIndexer(u.getContainerName()); // run indexer
        documentMetadataRepository.save(dm);
        documentRepository.save(d);
    }

    public DocumentMetadata getMetadata(String userID, Long docID)
            throws ResourceNotFoundException, UnauthorizedUserException{
        User u;
        Document d;

        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }

        return d.getMetadata();
    }

    public Map<String, String> getBlobMetadata(String userID, Long docID)
            throws ResourceNotFoundException, UnauthorizedUserException{
        User u;
        Document d;

        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }
        return getOrCreateContainerByOwner(u)
                .getBlobClient(d.getId().toString())
                .getBlockBlobClient()
                .getProperties()
                .getMetadata();
    }

    public ByteArrayOutputStream downloadDocument(String userID, Long docID)
            throws ResourceNotFoundException,IOException, UnauthorizedUserException {
        User u;
        Document d;
        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }
        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }
        BlobContainerClient blobContainerClient = getOrCreateContainerByOwner(d.getOwner());
        // Get a reference to a blob
        BlobClient blobClient = blobContainerClient.getBlobClient(d.getId().toString());
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        // download file from azure blob storage with stream
        logger.info("Trying to download file from blob");
        blobClient.downloadStream(baos);
        logger.info("File downloaded");
        return baos;
    }

    private boolean canRead(User u, Document d) {
        return d.getOwner().equals(u)
                || d.getReaders().contains(u);
    }

    public BlobContainerClient getContainerByOwner(User u){
        return blobServiceClient.getBlobContainerClient(u.getContainerName());
    }

    public BlobContainerClient getOrCreateContainerByOwner(User u){
        BlobContainerClient c = blobServiceClient.getBlobContainerClient(u.getContainerName());
        if(c.exists()) return c;
        else return createContainer(u);
    }

    private BlobContainerClient createContainer(User u){
        //Create a unique name for the container
        String containerName = u.getId();
        u.setContainerName(containerName);

        // Create the container and return a container client object
        BlobContainerClient blobContainerClient = blobServiceClient.createBlobContainer(containerName);

        // Connect the container with Azure Cognitive Search
        searchService.getOrCreateDataSourceConnection(containerName);
        searchService.getOrCreateSearchIndexer(containerName);
        return blobContainerClient;
    }
    public void deleteContainer(User u){
        String containerName = u.getContainerName();
        blobServiceClient.deleteBlobContainer(containerName);
    }


    @Transactional(propagation = Propagation.REQUIRED)
    public void addReader(String ownerID, String readerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException {
        User owner, reader;
        Document d;

        try {
            owner = userService.getById(ownerID);
            reader = userService.getById(readerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();
        if(owner.equals(reader)) return;

        d.addReader(reader);
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void addReaders(String ownerID, List<String> readersID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        List<User> readers = new LinkedList<>();
        Document d;

        try {
            owner = userService.getById(ownerID);
            for (String readerID: readersID) {
                User reader = userService.getById(readerID);
                if(owner.equals(reader)) continue;
                readers.add(reader);
            }
        
            d = documentService.getById(docID);
            if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();
            d.addReaders(readers);
    
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }
        documentRepository.save(d);
    }

        @Transactional(propagation = Propagation.REQUIRED)
    public void removeReaders(String ownerID, List<String> readersID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        List<User> readers = new LinkedList<>();
        Document d;

        try {
            owner = userService.getById(ownerID);
            for (String readerID: readersID) {
                readers.add(userService.getById(readerID));
            }
            d = documentService.getById(docID);
            if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();
            d.removeReaders(readers);

        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void removeReader(String ownerID, String readerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner, reader;
        Document d;

        try {
            owner = userService.getById(ownerID);
            reader = userService.getById(readerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();

        d.removeReader(reader);
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public List<User> getReadersByDoc(String ownerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        Document d;

        try {
            owner = userService.getById(ownerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();

        return d.getReaders();
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public List<User> getShareSuggestions(String ownerID) throws ResourceNotFoundException{
        User loggedUser;
        List<User> suggestions = new LinkedList<>();
        try {
            loggedUser = userService.getById(ownerID);
            for (Document d: loggedUser.getDocumentsOwned()) {
                suggestions.addAll(d.getReaders());
            }
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        return suggestions;
    }

}
