import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import 'audit_log_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();

  Stream<List<IncidentModel>> getIncidents() {
    return _db
        .collection('incidents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncidentModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateIncidentStatus(String incidentId, IncidentStatus status) async {
    await _db.collection('incidents').doc(incidentId).update({
      'status': status.name,
    });
    await _auditLogService.logAction(
      action: 'Status updated',
      module: 'Incident',
      newValue: status.name,
    );
  }

  Future<void> createIncident(Map<String, dynamic> data) async {
    await _db.collection('incidents').add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _auditLogService.logAction(
      action: 'Incident created',
      module: 'Incident',
    );
  }

  Future<void> updateIncident(String incidentId, Map<String, dynamic> data) async {
    await _db.collection('incidents').doc(incidentId).update(data);
  }

  Future<void> updateUserRole(String userId, String roleName) async {
    await _db.collection('users').doc(userId).update({'role': roleName});
    await _auditLogService.logAction(
      action: 'Role changed',
      module: 'User',
      newValue: roleName,
    );
  }

  Future<void> updateUserStatus(String userId, bool isBlacklisted) async {
    await _db.collection('users').doc(userId).update({'isBlacklisted': isBlacklisted});
    await _auditLogService.logAction(
      action: isBlacklisted ? 'User blacklisted' : 'User unblacklisted',
      module: 'User',
    );
  }

  Stream<List<UserModel>> getUsers() {
    return _db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getOrganizations() {
    return _db.collection('organizations').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  Future<void> updateOrganization(String orgId, Map<String, dynamic> data) async {
    await _db.collection('organizations').doc(orgId).set(data, SetOptions(merge: true));
    await _auditLogService.logAction(
      action: 'Organization updated',
      module: 'Admin',
      newValue: orgId,
    );
  }

  Stream<Map<String, int>> getDashboardStats() {
    return _db.collection('incidents').snapshots().map((snapshot) {
      final incidents =
          snapshot.docs.map((d) => IncidentModel.fromMap(d.data(), d.id)).toList();
      return {
        'total': incidents.length,
        'open': incidents.where((i) => i.status == IncidentStatus.open).length,
        'resolved':
            incidents.where((i) => i.status == IncidentStatus.resolved).length,
        'high': incidents
            .where((i) =>
                i.priority == IncidentPriority.high ||
                i.priority == IncidentPriority.critical)
            .length,
      };
    });
  }
}
