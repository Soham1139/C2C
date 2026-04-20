import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/incident_model.dart';
import '../../widgets/badges.dart';
import '../../widgets/create_incident_dialog.dart';

// Global providers are in app_providers.dart

class IncidentsScreen extends ConsumerWidget {
  const IncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentsAsync = ref.watch(incidentsStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final priorityFilter = ref.watch(priorityFilterProvider);
    final statusFilter = ref.watch(statusFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(context, ref, isDark),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: incidentsAsync.when(
                data: (incidents) {
                  var filtered = incidents;

                  if (searchQuery.isNotEmpty) {
                    filtered = filtered
                        .where((i) =>
                            i.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.location.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();
                  }

                  if (priorityFilter != null) {
                    filtered = filtered.where((i) => i.priority == priorityFilter).toList();
                  }

                  if (statusFilter != null) {
                    filtered = filtered.where((i) => i.status == statusFilter).toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'No incidents found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return _buildDataTable(context, ref, filtered, isDark);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, WidgetRef ref, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: 300,
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: TextField(
            style: GoogleFonts.inter(fontSize: 14),
            onChanged: (val) =>
                ref.read(searchQueryProvider.notifier).set(val),
            decoration: InputDecoration(
              hintText: 'Search incidents...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        _buildDropdownFilter<IncidentPriority>(
          context: context,
          isDark: isDark,
          hint: 'Priority',
          value: ref.watch(priorityFilterProvider),
          items: IncidentPriority.values,
          onChanged: (val) =>
              ref.read(priorityFilterProvider.notifier).set(val),
          labelBuilder: (p) => p.name.toUpperCase(),
        ),
        _buildDropdownFilter<IncidentStatus>(
          context: context,
          isDark: isDark,
          hint: 'Status',
          value: ref.watch(statusFilterProvider),
          items: IncidentStatus.values,
          onChanged: (val) =>
              ref.read(statusFilterProvider.notifier).set(val),
          labelBuilder: (s) => s.name,
        ),
        TextButton.icon(
          onPressed: () {
            ref.read(searchQueryProvider.notifier).set('');
            ref.read(priorityFilterProvider.notifier).set(null);
            ref.read(statusFilterProvider.notifier).set(null);
          },
          icon: const Icon(Icons.clear_all_rounded, size: 18),
          label: Text('Clear', style: GoogleFonts.inter(fontSize: 13)),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => const CreateIncidentDialog(),
            ),
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: Text(
              'New Incident',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFilter<T>({
    required BuildContext context,
    required bool isDark,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) labelBuilder,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T?>(
          value: value,
          hint: Text(hint,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text('All',
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.textPrimary)),
            ),
            ...items.map((item) => DropdownMenuItem<T?>(
                  value: item,
                  child: Text(labelBuilder(item),
                      style: GoogleFonts.inter(
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.textPrimary)),
                )),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDataTable(
      BuildContext context, WidgetRef ref, List<IncidentModel> incidents, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            headingRowHeight: 52,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            columnSpacing: 24,
            horizontalMargin: 24,
            columns: [
              DataColumn(
                  label: Text('TITLE',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text('PRIORITY',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text('STATUS',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text('LOCATION',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text('DATE',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
              DataColumn(
                  label: Text('ACTIONS',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5))),
            ],
            rows: incidents.map((incident) {
              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 180,
                      child: Text(
                        incident.title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(PriorityBadge(priority: incident.priority)),
                  DataCell(StatusBadge(status: incident.status)),
                  DataCell(
                    SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              incident.location,
                              style: GoogleFonts.inter(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(Text(
                    DateFormat('MMM d, y').format(incident.createdAt),
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                  )),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined, size: 18),
                          tooltip: 'View Details',
                          onPressed: () => _showDetailPanel(context, ref, incident, isDark),
                          color: AppColors.primary,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          tooltip: 'Update Status',
                          onPressed: () => _showStatusDialog(context, ref, incident),
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDetailPanel(
      BuildContext context, WidgetRef ref, IncidentModel incident, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 560,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.article_rounded, color: AppColors.primary, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      incident.title,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  PriorityBadge(priority: incident.priority),
                  const SizedBox(width: 8),
                  StatusBadge(status: incident.status),
                ],
              ),
              const SizedBox(height: 24),
              _detailRow(Icons.description_outlined, 'Description',
                  incident.description),
              const SizedBox(height: 16),
              _detailRow(
                  Icons.location_on_outlined, 'Location', incident.location),
              const SizedBox(height: 16),
              _detailRow(Icons.calendar_today_outlined, 'Created',
                  DateFormat('MMMM d, y – h:mm a').format(incident.createdAt)),
              const SizedBox(height: 16),
              _detailRow(Icons.person_outline, 'Reported By', incident.createdBy),
              if (incident.imageUrl != null && incident.imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    incident.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined,
                            size: 48, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showStatusDialog(context, ref, incident);
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Update Status'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: 400,
              child: Text(
                value,
                style: GoogleFonts.inter(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showStatusDialog(
      BuildContext context, WidgetRef ref, IncidentModel incident) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Status',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: IncidentStatus.values.map((status) {
              final isSelected = incident.status == status;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  tileColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : null,
                  leading: StatusBadge(status: status),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: AppColors.primary, size: 20)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await ref
                          .read(firestoreServiceProvider)
                          .updateIncidentStatus(incident.id, status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status updated to ${status.name}',
                              style: GoogleFonts.inter(),
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
