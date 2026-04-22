import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../widgets/organization_dialog.dart';
import '../widgets/super_admin_settings_dialog.dart';

class SuperAdminDashboard extends ConsumerWidget {
  const SuperAdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(usersStreamProvider);
    final orgsAsync = ref.watch(organizationsStreamProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Overview',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SuperAdminSettingsDialog(),
                  );
                },
                icon: const Icon(Icons.settings_suggest_rounded, size: 18),
                label: const Text('Platform Settings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statsAsync.when(
            data: (stats) => LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 3.0,
                  children: [
                    _buildOverviewCard(
                      'Total Incidents Managed',
                      '${stats['total'] ?? 0}',
                      Icons.local_police_rounded,
                      Colors.orangeAccent,
                      isDark,
                    ),
                  ],
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading stats: $err')),
          ),
          const SizedBox(height: 40),
          Text(
            'Organization Management',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          orgsAsync.when(
            data: (orgs) {
              if (orgs.isEmpty) {
                return _buildEmptyOrgState(context);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orgs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final org = orgs[index];
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(org['name'] ?? 'Untitled Organization', 
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(org['description'] ?? 'No description provided', 
                                style: GoogleFonts.inter(color: AppColors.textSecondary)),
                            if (org['emergencyPhone'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.phone_active_rounded, size: 14, color: AppColors.error),
                                  const SizedBox(width: 4),
                                  Text(org['emergencyPhone'], 
                                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                                ],
                              ),
                            ],
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                             showDialog(
                              context: context,
                              builder: (context) => OrganizationDialog(orgData: org),
                            );
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Manage'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading organizations: $err')),
          ),
          const SizedBox(height: 40),
          Text(
            'Admin & User Management',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          usersAsync.when(
            data: (users) => Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final user = users[index];
                  // Filter logic: Super Admin can see everyone, but focuses on Admins
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: user.isBlacklisted 
                            ? Colors.red.withValues(alpha: 0.1) 
                            : AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', 
                            style: TextStyle(color: user.isBlacklisted ? Colors.red : AppColors.primary)
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(user.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                                  if (user.isBlacklisted) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                      child: Text('BLACKLISTED', style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ],
                              ),
                              Text(user.email, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        _buildRoleDropdown(context, ref, user),
                        const SizedBox(width: 16),
                        _buildBlacklistToggle(context, ref, user),
                      ],
                    ),
                  );
                },
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading users: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrgState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.business_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('No Organizations Found', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Initialize your first organization to start managing tenants.', 
            style: GoogleFonts.inter(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const OrganizationDialog(),
              );
            },
            child: const Text('Add Organization'),
          ),
        ],
      ),
    );
  }

  Widget _buildBlacklistToggle(BuildContext context, WidgetRef ref, UserModel user) {
     return IconButton(
      tooltip: user.isBlacklisted ? 'Remove from Blacklist' : 'Blacklist User',
      icon: Icon(
        user.isBlacklisted ? Icons.security_update_good_rounded : Icons.person_off_rounded,
        color: user.isBlacklisted ? Colors.green : Colors.red,
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(user.isBlacklisted ? 'Unblock User?' : 'Blacklist User?'),
            content: Text(user.isBlacklisted 
              ? 'Are you sure you want to restore access for ${user.name}?' 
              : 'This will immediately revoke all access for ${user.name}. They will be logged out and cannot log back in.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true), 
                child: Text(user.isBlacklisted ? 'Restore' : 'Blacklist', style: TextStyle(color: user.isBlacklisted ? Colors.green : Colors.red)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            await ref.read(firestoreServiceProvider).updateUserStatus(user.id, !user.isBlacklisted);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(user.isBlacklisted ? 'User restored.' : 'User blacklisted.'))
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e'), backgroundColor: Colors.red));
          }
        }
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
