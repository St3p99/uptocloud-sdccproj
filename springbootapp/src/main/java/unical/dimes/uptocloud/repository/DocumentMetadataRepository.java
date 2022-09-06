package unical.dimes.uptocloud.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.DocumentMetadata;
import unical.dimes.uptocloud.model.User;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;

import java.util.Optional;


@Repository
public interface DocumentMetadataRepository extends JpaRepository<DocumentMetadata, Long> {

    Optional<DocumentMetadata> getByDocument(Document d);
}