import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogModel {
  final String id;
  final String userId;
  final String action;
  final String module;
  final String? oldValue;
  final String? newValue;
  final DateTime timestamp;

  AuditLogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.module,
    this.oldValue,
    this.newValue,
    required this.timestamp,
  });

  factory AuditLogModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AuditLogModel(
      id: documentId,
      userId: map['userId'] ?? '',
      action: map['action'] ?? '',
      module: map['module'] ?? '',
      oldValue: map['oldValue'],
      newValue: map['newValue'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'action': action,
      'module': module,
      'oldValue': oldValue,
      'newValue': newValue,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
