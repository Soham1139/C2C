import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'providers/auth_provider.dart';
import 'models/user_model.dart';
import 'providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: C2CApp()));
}

class C2CApp extends ConsumerWidget {
  const C2CApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'C2C - Command & Control Center',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: authState.when(
        data: (user) {
          if (user == null) return const LoginScreen();
          
          final profileAsync = ref.watch(userProfileProvider);
          return profileAsync.when(
            data: (profile) {
              if (profile == null) return const LoginScreen();
              if (profile.role == UserRole.field) {
                return const MainNavigationScreen();
              } else {
                return Scaffold(
                  body: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.computer_rounded, size: 80, color: Colors.orange),
                          const SizedBox(height: 24),
                          const Text(
                            'Administrative Access Required',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'The mobile application is for Field Users only. Please use the Web Control Center to manage the CCC system as an ${profile.role.name}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                            child: const Text('SIGN OUT'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
          );
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}