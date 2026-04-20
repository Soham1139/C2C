import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/incident_model.dart';
import '../../widgets/incident_widgets.dart';
import '../incidents/incident_detail_screen.dart';
import '../../services/firestore_service.dart';

import '../../widgets/sos_button.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incidentAsync = ref.watch(incidentStreamProvider);
    final filters = ref.watch(dashboardFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: incidentAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No incidents found', style: TextStyle(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }
          
          int total = incidents.length;
          int open = incidents.where((i) => i.status == IncidentStatus.open).length;
          int high = incidents.where((i) => i.priority == IncidentPriority.high).length;
          int resolved = incidents.where((i) => i.status == IncidentStatus.resolved).length;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      StatCard(
                        title: 'Total Incidents',
                        value: total.toString(),
                        icon: Icons.list_alt_rounded,
                        color: Colors.blue,
                        onTap: () {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(clearStatus: true, clearPriority: true));
                        },
                      ),
                      StatCard(
                        title: 'Open Cases',
                        value: open.toString(),
                        icon: Icons.visibility_rounded,
                        color: Colors.orange,
                        onTap: () {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(status: IncidentStatus.open, clearStatus: false, clearPriority: true));
                        },
                      ),
                      StatCard(
                        title: 'High Priority',
                        value: high.toString(),
                        icon: Icons.warning_rounded,
                        color: Colors.red,
                        onTap: () {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(priority: IncidentPriority.high, clearPriority: false, clearStatus: true));
                        },
                      ),
                      StatCard(
                        title: 'Resolved',
                        value: resolved.toString(),
                        icon: Icons.check_circle_rounded,
                        color: Colors.green,
                        onTap: () {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(status: IncidentStatus.resolved, clearStatus: false, clearPriority: true));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Recent Incidents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList.builder(
                  itemCount: incidents.length,
                  itemBuilder: (context, index) {
                    final incident = incidents[index];
                    return IncidentCard(
                      incident: incident,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IncidentDetailScreen(incident: incident),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)), // Space for FAB
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: const SOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    final currentFilters = ref.read(dashboardFilterProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filters = ref.watch(dashboardFilterProvider);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Filter Incidents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: IncidentPriority.values.map((p) {
                      final isSelected = filters.priority == p;
                      return ChoiceChip(
                        label: Text(p.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(priority: p, clearPriority: isSelected));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: IncidentStatus.values.map((s) {
                      final isSelected = filters.status == s;
                      return ChoiceChip(
                        label: Text(s.name.toUpperCase()),
                        selected: isSelected,
                        onSelected: (val) {
                          ref.read(dashboardFilterProvider.notifier).update(
                              filters.copyWith(status: s, clearStatus: isSelected));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('APPLY FILTERS'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
