import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident_model.dart';
import '../../core/theme/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final IncidentPriority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case IncidentPriority.critical:
        color = const Color(0xFFDC2626);
        break;
      case IncidentPriority.high:
        color = AppColors.warning;
        break;
      case IncidentPriority.medium:
        color = const Color(0xFF3B82F6);
        break;
      case IncidentPriority.low:
        color = AppColors.success;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        priority.name.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final IncidentStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case IncidentStatus.open:
        color = const Color(0xFFEF4444);
        label = 'Open';
        break;
      case IncidentStatus.inProgress:
        color = const Color(0xFFF59E0B);
        label = 'In Progress';
        break;
      case IncidentStatus.resolved:
        color = const Color(0xFF10B981);
        label = 'Resolved';
        break;
      case IncidentStatus.closed:
        color = const Color(0xFF6B7280);
        label = 'Closed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
