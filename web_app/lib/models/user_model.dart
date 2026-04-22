import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { super_admin, admin, operator, field, user }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final bool isBlacklisted;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isBlacklisted = false,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == (map['role'] ?? 'field'),
        orElse: () => UserRole.field,
      ),
      isBlacklisted: map['isBlacklisted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'isBlacklisted': isBlacklisted,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
