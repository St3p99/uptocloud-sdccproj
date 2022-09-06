package unical.dimes.uptocloud.service;

import org.springframework.http.HttpStatus;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.CreatedResponseUtil;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.keycloak.admin.client.resource.ClientResource;
import org.keycloak.admin.client.resource.RealmResource;
import org.keycloak.admin.client.resource.UserResource;
import org.keycloak.admin.client.resource.UsersResource;
import org.keycloak.representations.idm.ClientRepresentation;
import org.keycloak.representations.idm.CredentialRepresentation;
import org.keycloak.representations.idm.RoleRepresentation;
import org.keycloak.representations.idm.UserRepresentation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.repository.UserRepository;
import unical.dimes.uptocloud.support.exception.UniqueKeyViolationException;


import javax.ws.rs.core.Response;
import java.net.ConnectException;
import java.util.Arrays;
import java.util.Collections;
import java.util.Optional;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@Service
public class AccountingService {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    private final UserRepository userRepository;
    private final UserService userService;

    private final FileService fileService;

    @Value("${keycloak.auth-server-url}")
    private String serverUrl;
    @Value("${admin.username.keycloak}")
    private String adminUsername;
    @Value("${keycloak.client-key-password}")
    private String adminPwd;
    @Value("${keycloak.resource}")
    private String clientId;
    @Value("${keycloak.realm}")
    private String realm;
    @Value("${keycloak.credentials.secret}")
    private String clientSecret;
    @Value("${role-user}")
    private String USER_ROLE;
    private final SearchService searchService;


    @Autowired
    public AccountingService(UserRepository userRepository, UserService userService, FileService fileService, SearchService searchService) {
        this.userRepository = userRepository;
        this.userService = userService;
        this.fileService = fileService;
        this.searchService = searchService;
    }

    @Transactional
    public User registerUser(User user, String pwd) throws UniqueKeyViolationException, ConnectException {
        if (userRepository.existsByEmail(user.getEmail().toLowerCase())) {
            throw new UniqueKeyViolationException("ERROR_MAIL_USER_ALREADY_EXISTS");
        }
        if (userRepository.existsByUsername(user.getUsername().toLowerCase())) {
            throw new UniqueKeyViolationException("ERROR_USERNAME_ALREADY_EXISTS");
        }
        String userId = registerUserOnKeycloak(user, pwd);
        user.setId(userId);
        user.setEmail(user.getEmail().toLowerCase());
        return userService.createUser(user);
    }

    private String registerUserOnKeycloak(User user, String pwd){
        UsersResource usersResource = null;
        String userId = null;
        Response response = null;
        Keycloak keycloak = null;
        try{
            keycloak = getKeycloakObj();
            UserRepresentation userRepresentation = new UserRepresentation();

            userRepresentation.setEnabled(true);
            userRepresentation.setUsername(user.getEmail());
            userRepresentation.setEmail(user.getEmail());
            userRepresentation.setAttributes(Collections.singletonMap("origin", Arrays.asList("demo")));

            // Get realm
            RealmResource realmResource = keycloak.realm(realm);
            usersResource = realmResource.users();

            // Create user (requires manage-users role)
            response = usersResource.create(userRepresentation);
            userId = CreatedResponseUtil.getCreatedId(response);

            // Define password credential
            CredentialRepresentation passwordCred = new CredentialRepresentation();
            passwordCred.setTemporary(false);
            passwordCred.setType(CredentialRepresentation.PASSWORD);
            passwordCred.setValue(pwd);

            UserResource userResource = usersResource.get(userId);

            // Set password credential
            userResource.resetPassword(passwordCred);

            // Get client
            ClientRepresentation app1Client = realmResource.clients().findByClientId(clientId).get(0);

            // Get client level role (requires view-clients role)
            RoleRepresentation userClientRole = realmResource.clients().get(app1Client.getId()).roles().get(USER_ROLE).toRepresentation();

            // Assign client level role to user
            userResource.roles().clientLevel(app1Client.getId()).add(Arrays.asList(userClientRole));
        }catch (Exception e){
            logger.severe(e.toString());
            if(response != null) logger.warning(response.getStatus()+"");
            if(response != null && response.getStatus() == HttpStatus.CREATED.value()){
                usersResource.delete(userId);
            }
            return null;
        }
        return userId;
    }

    @Transactional
    public void deleteUser(String id) {
        Optional<User> opt = userRepository.findById(id);
        if (opt.isEmpty()) return;
        User user = opt.get();

        Keycloak keycloak = getKeycloakObj();

        // Get realm
        RealmResource realmResource = keycloak.realm(realm);
        UsersResource usersResource = realmResource.users();

        // delete user with email(unique)
        usersResource.delete(
                usersResource.search(user.getEmail(), true).get(0).getId()
        );


        if(fileService.getContainerByOwner(user).exists()){
            searchService.deleteDatasourceConnection(user.getContainerName());
            searchService.deleteSearchIndexer(user.getContainerName());
            fileService.deleteContainer(user);
        }
        userService.deleteUser(user);
    }

    private void assignRoleToUser(String userId, String role) {
        Keycloak keycloak = getKeycloakObj();
        UsersResource usersResource = keycloak.realm(realm).users();
        UserResource userResource = usersResource.get(userId);

        //getting client
        ClientRepresentation clientRepresentation = keycloak.realm(realm).clients().findAll().stream().filter(client -> client.getClientId().equals(clientId)).collect(Collectors.toList()).get(0);
        ClientResource clientResource = keycloak.realm(realm).clients().get(clientRepresentation.getId());
        //getting role
        RoleRepresentation roleRepresentation = clientResource.roles().list().stream().filter(element -> element.getName().equals(role)).collect(Collectors.toList()).get(0);
        //assigning to user
        userResource.roles().clientLevel(clientRepresentation.getId()).add(Collections.singletonList(roleRepresentation));
    }

    @Transactional(propagation = Propagation.SUPPORTS)
    public Keycloak getKeycloakObj() {
        return KeycloakBuilder.builder()
                .serverUrl(serverUrl)
                .realm(realm)
                .grantType(OAuth2Constants.PASSWORD)
                .clientId(clientId)
                .clientSecret(clientSecret)
                .username(adminUsername)
                .password(adminPwd)
                .build();
    }


}
