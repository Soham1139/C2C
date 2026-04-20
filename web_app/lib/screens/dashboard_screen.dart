import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/stat_card.dart';
import '../../models/incident_model.dart';
import '../../widgets/badges.dart';
import 'package:intl/intl.dart';

import '../../widgets/live_alert_panel.dart';
import '../../widgets/incident_table.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final incidentsAsync = ref.watch(incidentsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          incidentsAsync.maybeWhen(
            data: (incidents) => LiveAlertPanel(incidents: incidents),
            orElse: () => const SizedBox.shrink(),
          ),
          statsAsync.when(
            data: (stats) => _buildStatsGrid(stats, ref),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => _buildStatsGrid({'total': 0, 'open': 0, 'resolved': 0, 'high': 0}, ref),
          ),
          const SizedBox(height: 32),
          Text(
            'Operational Incident Management',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          incidentsAsync.when(
            data: (incidents) => IncidentTable(
              incidents: incidents,
              onTap: (incident) => _showIncidentDetails(context, ref, incident),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, WidgetRef ref, IncidentModel incident) {
    // We can implement a detailed view or dialog here
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(incident.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${incident.status.name.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Location: ${incident.location}'),
            const SizedBox(height: 8),
            Text('Description: ${incident.description}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CLOSE')),
          if (incident.status == IncidentStatus.open)
            ElevatedButton(
              onPressed: () {
                ref.read(incidentControllerProvider.notifier).updateStatus(incident.id, IncidentStatus.inProgress);
                Navigator.pop(context);
              },
              child: const Text('ACKNOWLEDGE'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats, WidgetRef ref) {
    void navigateToFilter(String? filter) {
      if (filter == 'open') {
        ref.read(statusFilterProvider.notifier).set(IncidentStatus.open);
        ref.read(priorityFilterProvider.notifier).set(null);
      } else if (filter == 'resolved') {
        ref.read(statusFilterProvider.notifier).set(IncidentStatus.resolved);
        ref.read(priorityFilterProvider.notifier).set(null);
      } else if (filter == 'high') {
        ref.read(priorityFilterProvider.notifier).set(IncidentPriority.high);
        ref.read(statusFilterProvider.notifier).set(null);
      } else {
        ref.read(statusFilterProvider.notifier).set(null);
        ref.read(priorityFilterProvider.notifier).set(null);
      }
      ref.read(sidebarIndexProvider.notifier).setIndex(1); // Navigate to Incidents tab
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.2,
          children: [
            StatCard(
              title: 'Total Incidents',
              value: '${stats['total'] ?? 0}',
              icon: Icons.assignment_rounded,
              color: AppColors.primary,
              trend: 'All Time',
              onTap: () => navigateToFilter(null),
            ),
            StatCard(
              title: 'Open Incidents',
              value: '${stats['open'] ?? 0}',
              icon: Icons.error_outline_rounded,
              color: AppColors.error,
              onTap: () => navigateToFilter('open'),
            ),
            StatCard(
              title: 'Resolved',
              value: '${stats['resolved'] ?? 0}',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
              onTap: () => navigateToFilter('resolved'),
            ),
            StatCard(
              title: 'High Priority',
              value: '${stats['high'] ?? 0}',
              icon: Icons.priority_high_rounded,
              color: AppColors.warning,
              onTap: () => navigateToFilter('high'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIncidentRow(IncidentModel incident, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              incident.title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          PriorityBadge(priority: incident.priority),
          const SizedBox(width: 12),
          StatusBadge(status: incident.status),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              DateFormat('MMM d, y').format(incident.createdAt),
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
