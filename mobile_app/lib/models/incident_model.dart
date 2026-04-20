import 'package:cloud_firestore/cloud_firestore.dart';

enum IncidentPriority { low, medium, high, critical }
enum IncidentStatus { open, inProgress, resolved, closed }
enum IncidentType { sos, security, medical, fire, other }

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final IncidentPriority priority;
  final IncidentType type;
  final String location;
  final String? imageUrl;
  final String createdBy;
  final String? assignedTo;
  final DateTime createdAt;
  final IncidentStatus status;
  final bool isSOS;
  final String? resolutionNotes;

  IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.type,
    required this.location,
    this.imageUrl,
    required this.createdBy,
    this.assignedTo,
    required this.createdAt,
    required this.status,
    this.isSOS = false,
    this.resolutionNotes,
  });

  factory IncidentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return IncidentModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: _parsePriority(map['priority']),
      type: _parseType(map['type']),
      location: map['location'] ?? '',
      imageUrl: map['imageUrl'],
      createdBy: map['createdBy'] ?? '',
      assignedTo: map['assignedTo'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: _parseStatus(map['status']),
      isSOS: map['isSOS'] ?? false,
      resolutionNotes: map['resolutionNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priority': priority.name,
      'type': type.name,
      'location': location,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'isSOS': isSOS,
      'resolutionNotes': resolutionNotes,
    };
  }

  static IncidentPriority _parsePriority(String? value) {
    switch (value) {
      case 'low': return IncidentPriority.low;
      case 'high': return IncidentPriority.high;
      case 'critical': return IncidentPriority.critical;
      default: return IncidentPriority.medium;
    }
  }

  static IncidentType _parseType(String? value) {
    switch (value) {
      case 'sos': return IncidentType.sos;
      case 'security': return IncidentType.security;
      case 'medical': return IncidentType.medical;
      case 'fire': return IncidentType.fire;
      default: return IncidentType.other;
    }
  }

  static IncidentStatus _parseStatus(String? value) {
    switch (value) {
      case 'inProgress': return IncidentStatus.inProgress;
      case 'resolved': return IncidentStatus.resolved;
      case 'closed': return IncidentStatus.closed;
      default: return IncidentStatus.open;
    }
  }
}

