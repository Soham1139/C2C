import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/audit_log_model.dart';

class AuditLogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logAction({
    String? userId,
    required String action,
    required String module,
    String? oldValue,
    String? newValue,
  }) async {
    try {
      final uid = userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'system';
      final log = AuditLogModel(
        id: '',
        userId: uid,
        action: action,
        module: module,
        oldValue: oldValue,
        newValue: newValue,
        timestamp: DateTime.now(),
      );
      await _firestore.collection('audit_logs').add(log.toMap());
    } catch (e) {
      print('Failed to log audit action: $e');
    }
  }
}
