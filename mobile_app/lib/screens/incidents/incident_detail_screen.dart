import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/incident_model.dart';
import '../../services/firestore_service.dart';
import '../../services/sop_service.dart';
import '../../providers/dashboard_provider.dart';
import '../../widgets/incident_widgets.dart';

class IncidentDetailScreen extends ConsumerStatefulWidget {
  final IncidentModel incident;

  const IncidentDetailScreen({super.key, required this.incident});

  @override
  ConsumerState<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends ConsumerState<IncidentDetailScreen> {
  final Set<int> _completedSteps = {};
  bool _isUpdating = false;

  void _toggleStep(int index) {
    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
      } else {
        _completedSteps.add(index);
      }
    });
  }

  Future<void> _updateStatus(IncidentStatus newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(firestoreServiceProvider).updateIncidentStatus(
            widget.incident.id,
            newStatus,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to ${newStatus.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sopSteps = SOPService.getStepsForType(widget.incident.type);
    final isSOS = widget.incident.isSOS;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSOS ? 'URGENT: SOS RESPONSE' : 'Incident Details'),
        backgroundColor: isSOS ? Colors.red[900] : null,
        foregroundColor: isSOS ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.incident.imageUrl != null)
              Image.network(
                widget.incident.imageUrl!,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PriorityBadge(priority: widget.incident.priority),
                      const SizedBox(width: 8),
                      _buildStatusBadge(widget.incident.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.incident.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM dd, yyyy • HH:mm').format(widget.incident.createdAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Divider(height: 32),
                  const Text(
                    'DESCRIPTION',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.incident.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'STANTARD OPERATING PROCEDURE (SOP)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  _buildSOPList(sopSteps),
                  const SizedBox(height: 32),
                  if (widget.incident.status != IncidentStatus.resolved) ...[
                    const Text(
                      'OPERATIONAL ACTIONS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (widget.incident.status == IncidentStatus.open)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isUpdating ? null : () => _updateStatus(IncidentStatus.inProgress),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('START RESPONSE'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                        if (widget.incident.status == IncidentStatus.inProgress)
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isUpdating ? null : () => _updateStatus(IncidentStatus.resolved),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('MARK AS RESOLVED'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSOPList(List<SOPStep> steps) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: steps.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final isCompleted = _completedSteps.contains(index);
          return ListTile(
            leading: Checkbox(
              value: isCompleted,
              onChanged: (_) => _toggleStep(index),
              activeColor: Colors.blue,
            ),
            title: Text(
              steps[index].description,
              style: TextStyle(
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                color: isCompleted ? Colors.grey : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(IncidentStatus status) {
    Color color;
    switch (status) {
      case IncidentStatus.open: color = Colors.blue; break;
      case IncidentStatus.inProgress: color = Colors.orange; break;
      case IncidentStatus.resolved: color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
