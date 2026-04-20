import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/incident_model.dart';
import 'audit_log_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditLogService _auditLogService = AuditLogService();

  Stream<List<IncidentModel>> getIncidents({
    IncidentPriority? priority,
    IncidentStatus? status,
  }) {
    Query query = _firestore.collection('incidents').orderBy('createdAt', descending: true);

    if (priority != null) {
      query = query.where('priority', isEqualTo: priority.name);
    }

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return IncidentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> createIncident(IncidentModel incident) async {
    try {
      await _firestore.collection('incidents').add(incident.toMap());
      await _auditLogService.logAction(
        action: 'Incident created',
        module: 'Incident',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> triggerSOS({required String userId, required String location}) async {
    final incident = IncidentModel(
      id: '',
      title: 'SOS EMERGENCY',
      description: 'Emergency SOS triggered from mobile device. Immediate assistance required.',
      priority: IncidentPriority.critical,
      type: IncidentType.sos,
      location: location,
      createdBy: userId,
      createdAt: DateTime.now(),
      status: IncidentStatus.open,
      isSOS: true,
    );

    try {
      await _firestore.collection('incidents').add(incident.toMap());
      await _auditLogService.logAction(
        action: 'SOS triggered',
        module: 'Incident',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateIncidentStatus(String id, IncidentStatus status, {String? notes}) async {
    try {
      final updates = <String, dynamic>{
        'status': status.name,
      };
      if (notes != null) {
        updates['resolutionNotes'] = notes;
      }
      await _firestore.collection('incidents').doc(id).update(updates);
      await _auditLogService.logAction(
        action: 'Status updated',
        module: 'Incident',
        newValue: status.name,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteIncident(String id) async {
    try {
      await _firestore.collection('incidents').doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
}
