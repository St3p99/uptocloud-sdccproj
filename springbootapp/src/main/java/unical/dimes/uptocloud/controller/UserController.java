package unical.dimes.uptocloud.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.service.AccountingService;
import unical.dimes.uptocloud.service.UserService;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import unical.dimes.uptocloud.support.exception.UniqueKeyViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.net.ConnectException;

@Controller
@RequestMapping("${base-url}/users")
public class UserController {
    private final AccountingService accountingService;
    private final UserService userService;


    @Autowired
    public UserController(AccountingService accountingService, UserService userService) {
        this.accountingService = accountingService;
        this.userService = userService;
    }

    /**
     * POST OPERATION
     **/
    @Operation(method = "newUser", summary = "Create a new user")
    @PostMapping(value = "/new")
    public ResponseEntity newUser(@RequestBody @Valid User user, BindingResult bindingResult, @RequestParam(value = "pwd") String pwd) {
        if (bindingResult.hasErrors()) return ResponseEntity.badRequest().build();
        try {
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(accountingService.registerUser(user, pwd));
        } catch (UniqueKeyViolationException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body(e.getMsg());
        } catch (ConnectException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("ERROR_CONNECTION");
        }
    }

    /**
     * GET OPERATION
     **/
    @Operation(method = "getUser", summary = "Retrieve user by Jwt")
    @GetMapping()
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getUser(@AuthenticationPrincipal Jwt principal) {
        try {
            return ResponseEntity.ok(userService.getById(principal.getSubject()));
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }


    @Operation(method = "getUserByEmail", summary = "Retrieve user by email")
    @GetMapping(value = "/byEmail/{email}")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getUserByEmail(@PathVariable String email) {
        try {
            return ResponseEntity.ok(userService.getByEmail(email));
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    @Operation(method = "getUserByEmailContains", summary = "Retrieve user if email contains specified string")
    @GetMapping(value = "/byEmail-contains/{email}")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity getUserByEmailContains(@PathVariable String email) {
        try {
            return ResponseEntity.ok(userService.getByEmailContains(email));
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found!");
        }
    }

    /**
     * DELETE OPERATION
     **/
    @Operation(method = "deleteUser", summary = "Delete user")
    @DeleteMapping("/delete")
    @PreAuthorize("hasAuthority('user')")
    public ResponseEntity deleteUser(@AuthenticationPrincipal Jwt principal) {
        accountingService.deleteUser(principal.getSubject());
        return ResponseEntity.noContent().build();    }

    @Operation(method = "deleteUser [ADMIN]", summary = "Delete a user (only admin)")
    @DeleteMapping("/delete/{id}")
    @PreAuthorize("hasAuthority('admin')")
    public ResponseEntity deleteUserAdmin(@PathVariable String id) {
        accountingService.deleteUser(id);
        return ResponseEntity.noContent().build();
    }


}
