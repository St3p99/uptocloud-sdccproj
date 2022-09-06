package unical.dimes.uptocloud.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import unical.dimes.uptocloud.model.User;

import java.util.Optional;



@Repository
public interface UserRepository extends JpaRepository<User, String> {
    boolean existsByEmail(String email);
    Optional<User> findByEmail(String email);
    Optional<User> findByEmailStartingWith(String email);

    boolean existsByUsername(String username);
}

