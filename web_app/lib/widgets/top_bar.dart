import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/notification_model.dart';

class TopBar extends ConsumerWidget {
  final String title;
  final String subtitle;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const TopBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifications
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final notifications = notificationsAsync.value ?? [];
    final unreadCount = notifications.where((n) => !n.read).length;

    // Watch user profile
    final userProfile = ref.watch(currentUserProfileProvider).value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 280,
            height: 42,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: TextField(
              style: GoogleFonts.inter(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
          const SizedBox(width: 8),
          
          // Notifications Dropdown
          PopupMenuButton<NotificationModel>(
            offset: const Offset(0, 50),
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            itemBuilder: (context) {
              if (notifications.isEmpty) {
                return [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('No notifications', style: GoogleFonts.inter()),
                  ),
                ];
              }
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notifications', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context); // Close menu
                            final user = ref.read(authStateProvider).value;
                            if (user != null) {
                              ref.read(notificationServiceProvider).markAllAsRead(user.uid);
                            }
                          },
                          child: const Text('Mark all read'),
                        ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                ...notifications.map((notif) => PopupMenuItem(
                      value: notif,
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    notif.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!notif.read)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notif.message,
                              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, h:mm a').format(notif.timestamp),
                              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    )),
              ];
            },
            onSelected: (notif) {
              if (!notif.read) {
                ref.read(notificationServiceProvider).markAsRead(notif.id);
              }
            },
          ),
          
          const SizedBox(width: 12),
          
          // Profile Dropdown
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.name ?? 'Loading...',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userProfile?.email ?? '',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 20),
                      SizedBox(width: 12),
                      Text('View Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authControllerProvider.notifier).signOut();
              } else if (value == 'profile') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile details coming soon')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
