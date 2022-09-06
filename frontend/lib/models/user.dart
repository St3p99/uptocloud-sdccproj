class User {
  String id;
  String email;
  String username;

  User({required this.id, required this.email, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'email': email, 'username': username};

  @override
  String toString() {
    return 'User{id: $id, email: $email, username: $username}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType
          && (id == other.id || email == other.email || username == other.username);

  @override
  int get hashCode => id.hashCode;
}
