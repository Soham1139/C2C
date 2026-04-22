import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/login_screen.dart';
import 'layouts/dashboard_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const ProviderScope(child: C2CDashboard()));
}

class C2CDashboard extends ConsumerWidget {
  const C2CDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDarkMode = ref.watch(isDarkModeProvider);

    return MaterialApp(
      title: 'C2C Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardLayout();
          }
          return const LoginScreen();
        },
        loading: () => const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing C2C...'),
              ],
            ),
          ),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Auth Error: $err')),
        ),
      ),
    );
  }
}
