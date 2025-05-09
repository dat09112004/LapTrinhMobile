import 'dart:convert';

class User {
  String id;
  String username;
  String password;
  String email;
  String? avatar;
  DateTime createdAt;
  DateTime lastActive;
  String role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.lastActive,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'].toString(),
      username: map['username'],
      password: map['password'],
      email: map['email'],
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      lastActive: DateTime.parse(map['lastActive']),
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'role': role,
    };
  }

  String toJSON() => jsonEncode(toMap());

  factory User.fromJSON(String source) => User.fromMap(jsonDecode(source));

  User copyWith({
    String? id,
    String? username,
    String? password,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? lastActive,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      role: role ?? this.role,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, role: $role)';
  }
}
