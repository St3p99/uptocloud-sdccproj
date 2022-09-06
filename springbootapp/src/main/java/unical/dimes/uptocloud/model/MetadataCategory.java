package unical.dimes.uptocloud.model;


import lombok.Getter;

@Getter

public enum MetadataCategory {
        ID("id"),
        DESCRIPTION("description"),
        TAGS("tags"),
        FILE_NAME("filename"),
        FILE_TYPE("fileType"),
        UPLOADED_AT("uploadedAt"),
        FILE_SIZE("fileSize");

        private final String name;
        public String toString(){ return name;}


        MetadataCategory(String string) {
                name = string;
        }
}