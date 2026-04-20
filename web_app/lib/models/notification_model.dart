import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String userId;
  final bool read;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.userId,
    this.read = false,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      userId: map['userId'] ?? '',
      read: map['read'] ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'userId': userId,
      'read': read,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
