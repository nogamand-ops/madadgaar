enum UserRole { customer, helper, admin }

UserRole userRoleFromString(String value) => UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.customer,
    );

class AppUser {
  final String id;
  final String phone;
  final String name;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    required this.createdAt,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        phone: json['phone'] as String,
        name: json['name'] as String,
        role: userRoleFromString(json['role'] as String),
        photoUrl: json['photoUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'role': role.name,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
      };
}
