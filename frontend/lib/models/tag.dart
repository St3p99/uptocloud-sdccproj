

class Tag {
  String name;

  Tag(
      {
        required this.name
      });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      name: json['name'],

    );
  }

  @override
  String toString() {
    return 'Tag{name: $name}';
  }

  Map<String, dynamic> toJson() => {
    'name': name
  };

}
