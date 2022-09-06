package unical.dimes.uptocloud.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.DocumentMetadata;
import unical.dimes.uptocloud.repository.DocumentMetadataRepository;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;

import java.util.logging.Logger;

@Service
public class DocumentMetadataService {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    private final DocumentMetadataRepository documentMetadataRepository;

    @Autowired
    public DocumentMetadataService(DocumentMetadataRepository documentMetadataRepository) {
        this.documentMetadataRepository = documentMetadataRepository;
    }

    public DocumentMetadata getById(Long id) throws ResourceNotFoundException{
        return documentMetadataRepository.findById(id).
                orElseThrow(ResourceNotFoundException::new);
    }

    public DocumentMetadata getByDocument(Document d) throws ResourceNotFoundException{
        return documentMetadataRepository.getByDocument(d).
                orElseThrow(ResourceNotFoundException::new);
    }

}


