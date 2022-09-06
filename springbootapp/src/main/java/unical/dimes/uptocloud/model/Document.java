package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.util.List;
import java.util.Objects;


/* lombok auto-generated code */
@Getter
@Setter
@ToString
/* lombok auto-generated code */

@Entity
@Table(
        name = "document",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "document_resource_name_id_unique",
                        columnNames = {"name", "owner_id"}
                )
        },
        schema = "public"
)
public class Document {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonIgnore
    @Column(name = "resource_url")
    private String resourceUrl;

    @NotNull
    @ManyToOne()
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @ManyToMany()
    @JoinTable(
            name = "reading_permissions",
            joinColumns = { @JoinColumn(name = "document_id") },
            inverseJoinColumns = { @JoinColumn(name = "reader_id") },

            schema = "public"
    )
    private List<User> readers;

    @OneToOne(mappedBy = "document", cascade = CascadeType.ALL)
    private DocumentMetadata metadata;

    public void addReader(User reader){
        if(!this.readers.contains(reader))
            this.readers.add(reader);
    }

    public void addReaders(List<User> readers){
        for (User reader: readers) {
            if(!this.readers.contains(reader)) this.readers.add(reader);
        }
    }

    public void removeReader(User reader){
        this.readers.remove(reader);
    }

    public void removeReaders(List<User> readers){
        this.readers.removeAll(readers);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        Document d = (Document) o;
        return Objects.equals(id, d.id);
    }

    @Override
    public int hashCode() {
        return this.id.hashCode();
    }
}
