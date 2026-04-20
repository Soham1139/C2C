import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import '../screens/dashboard_screen.dart';
import '../screens/incidents_screen.dart';
import '../screens/users_screen.dart';
import '../screens/super_admin_dashboard.dart';
import '../models/user_model.dart';
import '../core/theme/app_theme.dart';

class DashboardLayout extends ConsumerWidget {
  const DashboardLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(sidebarIndexProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userProfile = ref.watch(currentUserProfileProvider).value;
    final isSuperAdmin = userProfile?.role == UserRole.super_admin;
    
    final titles = ['Dashboard', 'Incidents', 'Users', if (isSuperAdmin) 'Admin Panel'];
    final subtitles = [
      'Overview of your command center',
      'Manage and track all incidents',
      'Team members and roles',
      if (isSuperAdmin) 'Super Admin Organization Management',
    ];

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isSuperAdmin: isSuperAdmin,
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              ref.read(sidebarIndexProvider.notifier).setIndex(index);
            },
            onLogout: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  title: titles[selectedIndex < titles.length ? selectedIndex : 0],
                  subtitle: subtitles[selectedIndex < subtitles.length ? selectedIndex : 0],
                  isDarkMode: isDarkMode,
                  onToggleTheme: () {
                    ref.read(isDarkModeProvider.notifier).toggle();
                  },
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.02, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildScreen(selectedIndex, isSuperAdmin),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(int index, bool isSuperAdmin) {
    switch (index) {
      case 0:
        return const DashboardScreen(key: ValueKey('dashboard'));
      case 1:
        return const IncidentsScreen(key: ValueKey('incidents'));
      case 2:
        return const UsersScreen(key: ValueKey('users'));
      case 3:
        if (isSuperAdmin) return const SuperAdminDashboard(key: ValueKey('admin'));
        return const DashboardScreen(key: ValueKey('dashboard'));
      default:
        return const DashboardScreen(key: ValueKey('dashboard'));
    }
  }
}
