import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/incident_model.dart';
import '../core/theme/app_theme.dart';

class LiveAlertPanel extends StatefulWidget {
  final List<IncidentModel> incidents;
  const LiveAlertPanel({super.key, required this.incidents});

  @override
  State<LiveAlertPanel> createState() => _LiveAlertPanelState();
}

class _LiveAlertPanelState extends State<LiveAlertPanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: AppColors.error,
      end: Colors.red.shade900,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final criticalIncidents = widget.incidents.where((i) => 
      (i.isSOS || i.priority == IncidentPriority.high) && i.status == IncidentStatus.open
    ).toList();
    
    if (criticalIncidents.isEmpty) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.02),
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3 + (_controller.value * 0.4)),
                  blurRadius: 10 + (_controller.value * 10),
                  spreadRadius: 2 + (_controller.value * 4),
                ),
              ],
            ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${criticalIncidents.length} CRITICAL / SOS ALERT ACTIVE',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Emergency triggers detected. Immediate tactical response required.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Scroll to incidents or open tactical view
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade900,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: const Text('VIEW EMERGENCY LOGS'),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}
