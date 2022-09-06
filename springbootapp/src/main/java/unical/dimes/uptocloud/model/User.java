package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.apache.commons.lang3.builder.EqualsExclude;
import org.apache.commons.lang3.builder.HashCodeExclude;

import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;
import java.util.List;
import java.util.Objects;
import java.util.Set;

/* lombok auto-generated code */
@Getter
@Setter
@ToString
/* lombok auto-generated code */

@Entity
@Table(
        name = "users",
        schema = "public"
)
public class User {
    /*     Utilizzata diagramma di tipo 3 per la generalizzazione (Non si materializza l'entità padre User)
    *    - si perde l'esclusività
    *    - va bene perchè User non ha relazioni
    * */

//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "id", nullable = false)
//    private Long id;

    @Id
    @Column(name = "id")
    private String id;

    @NotNull
    @Email
    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @NotNull
    @Column(name = "username", nullable = false, unique = true, length = 30)
    private String username;

    @JsonIgnore
    @Column(name = "container_name")
    private String containerName;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonIgnore
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
    @Column(insertable = false, updatable = false)
    private List<Document> documentsOwned;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonIgnore
    @ManyToMany(mappedBy = "readers")
    @Column(insertable = false, updatable = false)
    private List<Document> documentsReadable;

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        User user = (User) o;
        return Objects.equals(id, user.id);
    }

    public void removeReadingPermissions(){
        for (Document d: documentsReadable) {
            d.removeReader(this);
        }
    }

    @Override
    public int hashCode() {
        return this.id.hashCode();
    }
}
