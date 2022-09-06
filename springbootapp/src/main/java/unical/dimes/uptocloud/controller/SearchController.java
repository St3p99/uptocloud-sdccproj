package unical.dimes.uptocloud.controller;

import com.azure.search.documents.util.SearchPagedIterable;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.Tag;
import unical.dimes.uptocloud.service.DocumentService;
import unical.dimes.uptocloud.service.SearchService;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;

import javax.naming.directory.SearchResult;
import java.util.List;
import java.util.Set;


@RestController
@RequestMapping("${base-url}/search")
public class SearchController {

    private final DocumentService documentService;
    private final SearchService searchService;

    @Autowired
    public SearchController(DocumentService documentService, SearchService searchService) {
        this.documentService = documentService;
        this.searchService = searchService;
    }

    @Operation(method = "getRecentFilesOwned", summary = "Get recent files owned")
    @GetMapping(value = "/recent")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getRecentFilesOwned(@AuthenticationPrincipal Jwt principal) {
        try {
            List<Document> result = documentService.getRecentFilesOwned(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "getRecentFilesSharedWithMe", summary = "Get recent files shared with me")
    @GetMapping(value = "/recent-read-only")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getRecentFilesSharedWithMe(@AuthenticationPrincipal Jwt principal) {
        try {
            List<Document> result = documentService.getRecentFilesSharedWithMe(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }


    @Operation(method = "searchAnyFieldsContains", summary = "Retrieve documents by keywords searching in any fields")
    @GetMapping(value = "/any-fields-contains")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity searchAnyFieldsContains(@AuthenticationPrincipal Jwt principal, @RequestParam("text") String text,
                                                  @RequestParam("searchInContent") boolean searchInContent) {
        try {
            List<Document> result = searchService.searchAnyFieldsContains(principal.getSubject(), searchInContent, text);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
           return ResponseEntity.ok().body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "searchAnyFieldsContainsAndTags", summary = "Retrieve documents by keywords and tags searching in any fields")
    @GetMapping(value = "/any-fields-contains-and-tags")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity searchAnyFieldsContainsAndTags(@AuthenticationPrincipal Jwt principal, @RequestParam("text") String text, @RequestParam("tags") List<String> tags,
                                                         @RequestParam("searchInContent") boolean searchInContent) {
        try {
            List<Document> result = searchService.searchByAnyFieldsContainsAndTags(principal.getSubject(), searchInContent, text, tags);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok().body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "searchByTags", summary = "Retrieve documents by tags")
    @GetMapping(value = "/by-tags")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity searchByTags(@AuthenticationPrincipal Jwt principal, @RequestParam("tags") List<String> tags) {
        try {
            List<Document> result = searchService.searchByTags(principal.getSubject(),  tags);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok().body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "autocomplete", summary = "Autocomplete suggestions")
    @GetMapping(value = "/autocomplete")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity autocomplete(@AuthenticationPrincipal Jwt principal, @RequestParam("text") String text) {
        try {
            List<String> result = searchService.autocomplete(principal.getSubject(), text);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok().body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "getTagSuggestions", summary = "Get tag suggestions")
    @GetMapping(value = "/tag-suggestions")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getTagSuggestions(@AuthenticationPrincipal Jwt principal) {
        try {
            Set<Tag> result = searchService.getTagSuggestions(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.ok().body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }
}
