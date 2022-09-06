import 'dart:convert';

class EditMetadataModel{
  final String filename;
  final String description;
  final List<String>? tags;

  EditMetadataModel({required this.filename,required this.description,required this.tags});

  factory EditMetadataModel.fromJson(Map<String, dynamic> json) {
    return EditMetadataModel(
      filename: json['id'],
      description: json['name'],
      tags: json['tags'] == null ? null : List<String>.from(json['tags'].map((tag) => tag['name']).toList())
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'filename': filename,
        'description': description,
        'tags': tags == null ? null : jsonEncode(tags!)
      };

  @override
  String toString() {
    return 'EditMetadataModel{filename: $filename, description: $description, tags: $tags}';
  }
}