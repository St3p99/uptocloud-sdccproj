package unical.dimes.uptocloud.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.apache.http.HttpHeaders;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBodyReturnValueHandler;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.DocumentMetadata;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.service.DocumentService;
import unical.dimes.uptocloud.service.FileService;
import unical.dimes.uptocloud.support.exception.FileSizeExceededException;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import unical.dimes.uptocloud.support.exception.UnauthorizedUserException;
import unical.dimes.uptocloud.support.exception.UniqueKeyViolationException;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.LinkedList;
import java.util.List;

@RestController
@RequestMapping("${base-url}/files")
public class FileController {

    private final FileService fileService;

    @Value("${max-file-size}")
    private long max_file_size;
    private final DocumentService documentService;

    @Autowired
    public FileController(FileService fileService, DocumentService documentService) {
        this.fileService = fileService;
        this.documentService = documentService;
    }

    @Operation(method = "uploadFile", summary = "Upload a file as a blob in the user's container")
    @PreAuthorize("hasAuthority('user')")
    @PostMapping(value = "/upload", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<?> uploadFile(@AuthenticationPrincipal Jwt principal, @RequestParam("file") MultipartFile file) {
        try {
            Document d = fileService.uploadDocument(principal.getSubject(), file);
            return ResponseEntity.status(200).body(d);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }catch (UniqueKeyViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
        catch (FileSizeExceededException e) {
            return ResponseEntity.badRequest().body("File size exceeded -- FILE SIZE LIMIT: " + max_file_size + "MB");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(method = "deleteFile", summary = "Delete a file")
    @PreAuthorize("hasAuthority('user')")
    @DeleteMapping(value = "/delete/{doc_id}")
    public ResponseEntity<?> deleteFile(@AuthenticationPrincipal Jwt principal, @PathVariable("doc_id") Long docID) {
        try {
            fileService.deleteDocument(principal.getSubject(), docID);
            return ResponseEntity.status(200).build();
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.badRequest().body("User must be the owner of the specified document");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(method = "deleteFiles", summary = "Delete files")
    @PreAuthorize("hasAuthority('user')")
    @DeleteMapping(value = "/delete")
    public ResponseEntity<?> deleteFiles(@AuthenticationPrincipal Jwt principal, @RequestParam("docs_id") List<Long> docsID) {
        try {
            fileService.deleteDocuments(principal.getSubject(), docsID);
            return ResponseEntity.status(200).build();
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.badRequest().body("User must be the owner of the specified document");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(method = "setMetadata", summary = "Set metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @PostMapping(value = "/set_metadata/{doc_id}", consumes = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> setMetadata(@AuthenticationPrincipal Jwt principal,
                                         @PathVariable("doc_id") Long docID,
                                         @RequestParam("filename") String filename,
                                         @RequestParam(name="description", required = false, defaultValue = "") String description,
                                         @RequestParam(name = "tags", required = false, defaultValue = "") List<String> tags) {
        try {
            fileService.setMetadata(principal.getSubject(), docID, filename, description,tags);
            return ResponseEntity.status(200).build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must be the owner of the specified document");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "getMetadata", summary = "Get metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/get_metadata/{doc_id}", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getMetadata(@AuthenticationPrincipal Jwt principal,
                                         @PathVariable("doc_id") Long docID) {
        try {
            DocumentMetadata metadata = fileService.getMetadata(principal.getSubject(), docID);
            return ResponseEntity.status(200)
                    .body(metadata);
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "getBlobMetadata", summary = "Get Blob metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/get_blob_metadata/{doc_id}", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getBlobMetadata(@AuthenticationPrincipal Jwt principal,
                                             @PathVariable("doc_id") Long docID) {
        try {
            return ResponseEntity.status(200)
                    .body(fileService.getBlobMetadata(principal.getSubject(), docID));
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "downloadFile", summary = "Download the specified file")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/download/{doc_id}", produces = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<?> downloadFile(@AuthenticationPrincipal Jwt principal, @PathVariable("doc_id") Long docID) {
        try {
            final ByteArrayResource resource =
                new ByteArrayResource(
                    fileService.downloadDocument(principal.getSubject(), docID).toByteArray()
                );
            Document d = documentService.getById(docID);
                return ResponseEntity
                        .ok()
                        .header(HttpHeaders.CONTENT_TYPE, d.getMetadata().getFileType())
                        .header("Access-Control-Expose-Headers", "Content-Disposition")
                        .header("Content-Disposition", "attachment; filename=" + d.getName())
                        .contentLength(resource.contentLength())
                        .body(resource);
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions to download the file");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }


    @Operation(method = "addReader", summary = "Add a reader to the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/add-reader")
    public ResponseEntity<?> addReader(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("reader_id") String readerID) {
        try {
            fileService.addReader(principal.getSubject(), readerID, docID);
            return ResponseEntity.status(200).build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "addReaders", summary = "Add readers to the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/add-readers")
    public ResponseEntity<?> addReaders(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("readers_id") List<String> readersID) {
        try {
            fileService.addReaders(principal.getSubject(), readersID, docID);
            return ResponseEntity.status(200).build();

        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "removeReader", summary = "Remove a reader from the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/remove-reader")
    public ResponseEntity<?> removeReader(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("reader_id") String readerID) {
        try {
            fileService.removeReader(principal.getSubject(), readerID, docID);
            return ResponseEntity.status(200).build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "removeReaders", summary = "Remove readers from the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/remove-readers")
    public ResponseEntity<?> removeReaders(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("readers_id") List<String> readersID) {
        try {
            fileService.removeReaders(principal.getSubject(), readersID, docID);
            return ResponseEntity.status(200).build();

        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "getReadersByDoc", summary = "Get readers of specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/readersByDoc")
    public ResponseEntity<?> getReadersByDoc(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID) {
        try {
            List<User> result = fileService.getReadersByDoc(principal.getSubject(), docID);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.status(200).body(result);
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "getShareSuggestions", summary = "Get users that are readers of at least one document owned by logged user")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/share-suggestions")
    public ResponseEntity<?> getShareSuggestions(@AuthenticationPrincipal Jwt principal) {
        try {
            List<User> result = fileService.getShareSuggestions(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.status(200).body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
}