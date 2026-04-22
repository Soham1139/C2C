import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';

class SuperAdminSettingsDialog extends StatefulWidget {
  const SuperAdminSettingsDialog({super.key});

  @override
  State<SuperAdminSettingsDialog> createState() => _SuperAdminSettingsDialogState();
}

class _SuperAdminSettingsDialogState extends State<SuperAdminSettingsDialog> {
  bool _notificationsEnabled = true;
  double _timeout = 30.0;
  String _theme = 'System';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Settings',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Global configuration for the C2C Platform.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: Text('Push Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              subtitle: Text('Enable real-time alerts for all operators', style: GoogleFonts.inter(fontSize: 12)),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
              activeColor: AppColors.primary,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Incident Auto-Refresh Timeout (seconds)', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  Slider(
                    value: _timeout,
                    min: 10,
                    max: 120,
                    divisions: 11,
                    label: _timeout.round().toString(),
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _timeout = val),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              title: Text('Default System Theme', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              trailing: DropdownButton<String>(
                value: _theme,
                items: ['System', 'Light', 'Dark']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _theme = val!),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Save logic would go here
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(120, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
