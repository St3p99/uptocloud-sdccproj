class FileDataModel{
  final String name;
  final String mime;
  final int bytes;
  final String url;
  final Stream<List<int>> stream;

  FileDataModel({required this.name,required this.mime,required this.bytes, required this.url, required this.stream});

  String get size{
    final kb = bytes / 1024;
    final mb = kb / 1024;

    return mb > 1 ? '${mb.toStringAsFixed(2)} MB' : '${kb.toStringAsFixed(2)} KB';
  }

  @override
  String toString() {
    return 'FileDataModel{name: $name, mime: $mime, bytes: $bytes, url: $url}';
  }
}