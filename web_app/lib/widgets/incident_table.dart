import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/incident_model.dart';
import '../core/theme/app_theme.dart';
import 'badges.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../models/user_model.dart';

class IncidentTable extends ConsumerWidget {
  final List<IncidentModel> incidents;
  final Function(IncidentModel) onTap;

  const IncidentTable({
    super.key,
    required this.incidents,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rowColor = isDark ? AppColors.darkCard : Colors.white;
    final headerColor = isDark ? Colors.grey[900] : Colors.grey[50];
    final usersAsync = ref.watch(usersStreamProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(headerColor, isDark),
          if (incidents.isEmpty)
            _buildEmptyState(isDark)
          else
            ...incidents.map((incident) => _buildRow(incident, isDark, context, ref, usersAsync)),
        ],
      ),
    );
  }

  Widget _buildHeader(Color? color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _headerCell('ID', 1),
          _headerCell('REPORT', 3),
          _headerCell('PRIORITY', 2),
          _headerCell('TYPE', 2),
          _headerCell('STATUS', 2),
          _headerCell('ASSIGNEE', 2),
          _headerCell('CREATED', 2, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _headerCell(String label, int flex, {TextAlign align = TextAlign.left}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        textAlign: align,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildRow(
    IncidentModel incident, 
    bool isDark, 
    BuildContext context, 
    WidgetRef ref,
    AsyncValue<List<UserModel>> usersAsync,
  ) {
    return InkWell(
      onTap: () => onTap(incident),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '#${incident.id.substring(0, 4)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    incident.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    incident.location,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: PriorityBadge(priority: incident.priority),
            ),
            Expanded(
              flex: 2,
              child: _buildTypeBadge(incident.type, isDark),
            ),
            Expanded(
              flex: 2,
              child: StatusBadge(status: incident.status),
            ),
            Expanded(
              flex: 2,
              child: usersAsync.when(
                data: (users) {
                  final fieldUsers = users.where((u) => u.role == UserRole.field).toList();
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: incident.assignedTo,
                      hint: const Text('Unassigned', style: TextStyle(fontSize: 12)),
                      isExpanded: true,
                      style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.white : Colors.black),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('None', style: TextStyle(fontSize: 12)),
                        ),
                        ...fieldUsers.map((user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.name, style: const TextStyle(fontSize: 12)),
                        )),
                      ],
                      onChanged: (userId) {
                        ref.read(incidentControllerProvider.notifier).assignIncident(incident.id, userId);
                      },
                    ),
                  );
                },
                loading: () => const Text('...', style: TextStyle(fontSize: 12)),
                error: (_, __) => const Text('Error', style: TextStyle(fontSize: 12)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('HH:mm | MMM d').format(incident.createdAt),
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(IncidentType type, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getTypeIcon(type), size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            type.name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(IncidentType type) {
    switch (type) {
      case IncidentType.sos: return Icons.emergency_rounded;
      case IncidentType.security: return Icons.security_rounded;
      case IncidentType.medical: return Icons.medical_services_rounded;
      case IncidentType.fire: return Icons.local_fire_department_rounded;
      default: return Icons.miscellaneous_services_rounded;
    }
  }

  Widget _buildEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(64),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active incidents at this time',
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
