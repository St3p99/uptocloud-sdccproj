package unical.dimes.uptocloud.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.User;

import java.util.Optional;


@Repository
public interface DocumentRepository extends JpaRepository<Document, Long> {

    Optional<Document> getByOwnerAndName(User owner, String filename);

    boolean existsByNameAndOwner(String name, User u);

}