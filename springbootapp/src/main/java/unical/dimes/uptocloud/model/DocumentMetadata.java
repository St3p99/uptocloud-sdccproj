package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.Objects;

/* lombok auto-generated code */
@Getter
@Setter
@ToString
/* lombok auto-generated code */
@Entity
@Table(
        name = "document_metadata",
        schema = "public"
)
public class DocumentMetadata {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @JsonBackReference
    @ToString.Exclude
    @OneToOne()
    @JoinColumn(name = "document_id", unique = true, nullable = false)
    public Document document;

    @Basic
    @Column(name = "description", columnDefinition = "text")
    private String description;

    @Basic
    @CreationTimestamp
    @Temporal(TemporalType.TIMESTAMP)
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    @Column(name = "uploadedAt")
    private Date uploadedAt;

    @Column(name = "file_type")
    private String fileType;

    @Column(name = "file_size")
    private Long fileSize;

    @ManyToMany(cascade = { CascadeType.ALL })
    @JoinTable(
            name = "document_metadata_tag",
            joinColumns = { @JoinColumn(name = "document_metadata_id") },
            inverseJoinColumns = { @JoinColumn(name = "tag_id") },
            schema = "public"
    )
    private List<Tag> tags;





    public DocumentMetadata() {}
    public DocumentMetadata(Document d){this.document = d;}

    public LocalDateTime getUploadedAtLocalDateTime(){
        return document.getMetadata().getUploadedAt().toInstant().atZone(ZoneId.systemDefault()).toLocalDateTime();
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof User)) return false;
        DocumentMetadata d = (DocumentMetadata) o;
        return Objects.equals(id, d.id);
    }

    @Override
    public int hashCode() {
        return this.id.hashCode();
    }
}
