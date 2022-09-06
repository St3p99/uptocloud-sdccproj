package unical.dimes.uptocloud.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.repository.UserRepository;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;


@Service
public class UserService {
    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public User getById(String id) throws ResourceNotFoundException {
        return userRepository.findById(id).
                orElseThrow(ResourceNotFoundException::new);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void deleteUser(User user) {
        user.removeReadingPermissions();
        userRepository.delete(user);
    }


    @Transactional(readOnly = true)
    public User getByEmail(String email) throws ResourceNotFoundException {
        return userRepository.findByEmail(email).
                orElseThrow(ResourceNotFoundException::new);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public User createUser(User user){
        return userRepository.save(user);
    }

    public Object getByEmailContains(String email) throws ResourceNotFoundException {
        return userRepository.findByEmailStartingWith(email.toLowerCase()).
                orElseThrow(ResourceNotFoundException::new);
    }
}
