import '../support/file_utils.dart';
import 'document_metadata.dart';
import 'user.dart';

const int FILE_SIZE_FRACTION_DIGITS = 2;

class Document {
  String? icon;
  int id;
  String name;
  User owner;
  DocumentMetadata metadata;

  Document({
    required this.id,
    required this.name,
    required this.owner,
    required this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      name: json['name'],
      owner: json['owner'] = User.fromJson(json["owner"]),
      metadata: json['metadata'] = DocumentMetadata.fromJson(json["metadata"]),
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'owner': owner.toJson(),
        'metadata': metadata.toJson()
      };

  @override
  String toString() {
    return 'Document{id: $id, name: $name, owner: $owner, metadata: $metadata}';
  }

  void loadIcon() {
    icon = FileUtils.loadIcon(this.metadata.fileType);
  }

  String getFileSize(){
    return FileUtils.getFileSize(this.metadata.fileSize);
  }



}

List<Document> demoFiles = [
  Document(
      id: 1,
      name: "file.pdf",
      metadata: new DocumentMetadata(
        id: 1, uploadedAt: DateTime.parse("2022-03-11 12:23:44"), fileType: "application/pdf", fileSize: 13122113,
        description: "È un file pdf."
      ),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 2,
      name: "file.txt",
      metadata: new DocumentMetadata(
          description: "È un file txt.",
          id: 1, uploadedAt: DateTime.parse("2022-03-17 09:23:44"), fileType: "text/plain", fileSize: 11122213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 3,
      name: "file.docx",
      metadata: new DocumentMetadata(
          description: "È un file docx.",
          id: 1, uploadedAt: DateTime.parse("2022-03-19 22:23:44"), fileType: "application/msword", fileSize: 21312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 19,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 19, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 531312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 20,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 20, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 831312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 21,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 21, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 73122113),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 22,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 22, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 53121213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 23,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 23, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 221312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 24,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 24, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 55312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 25,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 25, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 712312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 26,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 26, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 14124413),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
  Document(
      id: 27,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 27, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 6524312213),
      owner: new User(username: 'user1', id: '1', email: 'user1@mail.com')
  ),
];

List<Document> demoFilesShared = [
  Document(
      id: 4,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 4, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 254324523),
      owner: new User(username: 'user4', id: '4', email: 'user4@mail.com')
  ),
  Document(
      id: 5,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 5, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 762154116),
      owner: new User(username: 'user2', id: '1', email: 'user2@mail.com')
  ),
  Document(
      id: 6,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 6, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 836111),
      owner: new User(username: 'user3', id: '3', email: 'user3@mail.com')
  ),
  Document(
      id: 7,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 7, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 81217341),
      owner: new User(username: 'user4', id: '4', email: 'user4@mail.com')
  ),
  Document(
      id: 8,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 8, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 127491),
      owner: new User(username: 'user2', id: '1', email: 'user2@mail.com')
  ),
  Document(
      id: 9,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 9, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 9412712),
      owner: new User(username: 'user3', id: '3', email: 'user3@mail.com')
  ),
  Document(
      id: 10,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 10, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 912749),
      owner: new User(username: 'user4', id: '4', email: 'user4@mail.com')
  ),
  Document(
      id: 11,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 11, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 216439612),
      owner: new User(username: 'user2', id: '1', email: 'user2@mail.com')
  ),
  Document(
      id: 12,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 12, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 912741),
      owner: new User(username: 'user3', id: '3', email: 'user3@mail.com')
  ),
  Document(
      id: 13,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 13, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 12412),
      owner: new User(username: 'user4', id: '4', email: 'user4@mail.com')
  ),
  Document(
      id: 14,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 14, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 732481),
      owner: new User(username: 'user2', id: '1', email: 'user2@mail.com')
  ),
  Document(
      id: 15,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 15, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 6517658),
      owner: new User(username: 'user3', id: '3', email: 'user3@mail.com')
  ),
  Document(
      id: 16,
      name: "file.pdf",
      metadata: new DocumentMetadata(
          id: 16, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/pdf", fileSize: 713741),
      owner: new User(username: 'user4', id: '4', email: 'user4@mail.com')
  ),
  Document(
      id: 17,
      name: "file.txt",
      metadata: new DocumentMetadata(
          id: 17, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "text/plain", fileSize: 1274114),
      owner: new User(username: 'user2', id: '1', email: 'user2@mail.com')
  ),
  Document(
      id: 18,
      name: "file.docx",
      metadata: new DocumentMetadata(
          id: 18, uploadedAt: DateTime.parse("2022-03-13 10:23:44"), fileType: "application/msword", fileSize: 41297401),
      owner: new User(username: 'user3', id: '3', email: 'user3@mail.com')
  ),
];
