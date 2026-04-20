import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/incident_model.dart';

class PriorityBadge extends StatelessWidget {
  final IncidentPriority priority;
  const PriorityBadge({super.key, required this.priority});

  Color get _color {
    switch (priority) {
      case IncidentPriority.critical:
        return Colors.red[900]!;
      case IncidentPriority.high:
        return Colors.red;
      case IncidentPriority.medium:
        return Colors.orange;
      case IncidentPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withOpacity(0.5)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: TextStyle(color: _color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;

  const IncidentCard({super.key, required this.incident, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: incident.isSOS && incident.status == IncidentStatus.open
            ? Border.all(color: Colors.red, width: 2)
            : null,
        boxShadow: incident.isSOS && incident.status == IncidentStatus.open
            ? [BoxShadow(color: Colors.red.withOpacity(0.2), blurRadius: 10, spreadRadius: 2)]
            : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (incident.imageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: incident.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PriorityBadge(priority: incident.priority),
                        const SizedBox(width: 8),
                        _buildTypeBadge(incident.type),
                        const Spacer(),
                        Text(
                          incident.status.name.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(incident.status),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      incident.title,
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: incident.isSOS ? Colors.red[900] : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      incident.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.location,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),
                        Text(
                          DateFormat('HH:mm').format(incident.createdAt),
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(IncidentType type) {
    IconData icon;
    switch (type) {
      case IncidentType.sos: icon = Icons.emergency; break;
      case IncidentType.security: icon = Icons.security; break;
      case IncidentType.medical: icon = Icons.medical_services; break;
      case IncidentType.fire: icon = Icons.local_fire_department; break;
      default: icon = Icons.miscellaneous_services;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.black54),
          const SizedBox(width: 4),
          Text(
            type.name.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.open:
        return Colors.blue;
      case IncidentStatus.inProgress:
        return Colors.orange;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.closed:
        return Colors.grey;
    }
  }
}
