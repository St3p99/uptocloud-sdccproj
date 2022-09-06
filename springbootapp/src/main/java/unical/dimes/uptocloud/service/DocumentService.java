package unical.dimes.uptocloud.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.repository.DocumentMetadataRepository;
import unical.dimes.uptocloud.repository.DocumentRepository;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.LinkedList;
import java.util.logging.Logger;
import java.util.List;

@Service
public class DocumentService {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    private final DocumentRepository documentRepository;
    private final DocumentMetadataRepository documentMetadataRepository;
    private final UserService userService;

    @Autowired
    public DocumentService(DocumentRepository documentRepository, DocumentMetadataRepository documentMetadataRepository, UserService userService) {
        this.documentRepository = documentRepository;
        this.documentMetadataRepository = documentMetadataRepository;
        this.userService = userService;
    }

    public Document getById(Long id) throws ResourceNotFoundException{
        return documentRepository.findById(id).
                orElseThrow(ResourceNotFoundException::new);
    }

    public List<Document> getRecentFilesOwned(String userID) throws ResourceNotFoundException {
        User u = userService.getById(userID);
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(60);
        List<Document> ret = new LinkedList<>();
        u.getDocumentsOwned().forEach(
                document -> {
                    if(document.getMetadata().getUploadedAtLocalDateTime().compareTo(start) >= 0 &&
                            document.getMetadata().getUploadedAtLocalDateTime().compareTo(end) <= 0){
                        ret.add(document);
                    }
                }
        );
        return ret;
    }

    public List<Document> getRecentFilesSharedWithMe(String userID) throws ResourceNotFoundException {
        User u = userService.getById(userID);
        LocalDateTime end = LocalDateTime.now();
        LocalDateTime start = end.minusDays(60);
        List<Document> ret = new LinkedList<>();
        u.getDocumentsReadable().forEach(
                document -> {
                    if(document.getMetadata().getUploadedAtLocalDateTime().compareTo(start) >= 0 &&
                            document.getMetadata().getUploadedAtLocalDateTime().compareTo(end) <= 0){
                        ret.add(document);
                    }
                }
        );
        return ret;
    }
}


