package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.util.List;
import java.util.Objects;

/* lombok auto-generated code */
@Getter
@Setter
@ToString
/* lombok auto-generated code */

@Entity
@Table(
        name = "tag",
        schema = "public",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "tag_name_id_unique",
                        columnNames = {"name"}
                )
        }
)
public class Tag {
    @JsonIgnore
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Basic
    @Column(name = "name")
    private String name;

    @JsonIgnore
    @ManyToMany(mappedBy = "tags")
    private List<DocumentMetadata> documents;

    public Tag(){}
    public Tag(String name){this.name = name;}

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof Tag)) return false;
        Tag tag = (Tag) o;
        return name.equals(tag.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(name);
    }
}

