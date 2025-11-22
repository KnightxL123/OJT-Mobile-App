class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final int? departmentId;
  final String? phone;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.departmentId,
    this.phone,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
      departmentId: json['department_id'],
      phone: json['phone'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'department_id': departmentId,
      'phone': phone,
      'created_at': createdAt.toIso8601String(),
    };
  }
}