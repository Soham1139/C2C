import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/user_model.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.people_rounded,
                        color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Management',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Manage team members and roles',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_off_rounded,
                              size: 56, color: AppColors.textSecondary),
                          const SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: users.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return _buildUserTile(user, isDark);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTile(UserModel user, bool isDark) {
    final isAdmin = user.role == UserRole.admin;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isAdmin
                ? [AppColors.primary, AppColors.accent]
                : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      title: Text(
        user.name,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        user.email,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isAdmin
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : const Color(0xFF6366F1).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAdmin
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : const Color(0xFF6366F1).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              user.role.name.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isAdmin ? AppColors.primary : const Color(0xFF6366F1),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            DateFormat('MMM d, y').format(user.createdAt),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
