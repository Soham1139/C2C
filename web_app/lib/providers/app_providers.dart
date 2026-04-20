import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../models/incident_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        return UserModel.fromMap(doc.data()!, doc.id);
      });
});

class AuthController extends AsyncNotifier<void> {
  late final AuthService _authService;

  @override
  FutureOr<void> build() {
    _authService = ref.read(authServiceProvider);
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signIn(email: email, password: password));
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signOut());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

final incidentsStreamProvider = StreamProvider<List<IncidentModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getIncidents();
});

final usersStreamProvider = StreamProvider<List<UserModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getUsers();
});

final dashboardStatsProvider = StreamProvider<Map<String, int>>((ref) {
  return ref.watch(firestoreServiceProvider).getDashboardStats();
});

final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(notificationServiceProvider).getUserNotifications(user.uid);
});

class SidebarNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final sidebarIndexProvider = NotifierProvider<SidebarNotifier, int>(() {
  return SidebarNotifier();
});

class ThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

final isDarkModeProvider = NotifierProvider<ThemeModeNotifier, bool>(() {
  return ThemeModeNotifier();
});

class IncidentController extends AsyncNotifier<void> {
  late final FirestoreService _firestoreService;

  @override
  FutureOr<void> build() {
    _firestoreService = ref.read(firestoreServiceProvider);
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.updateIncidentStatus(id, status));
  }

  Future<void> assignIncident(String id, String? userId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.updateIncident(id, {'assignedTo': userId}));
  }
}

final incidentControllerProvider = AsyncNotifierProvider<IncidentController, void>(() {
  return IncidentController();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String val) => state = val;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class PriorityFilterNotifier extends Notifier<IncidentPriority?> {
  @override
  IncidentPriority? build() => null;
  void set(IncidentPriority? val) => state = val;
}
final priorityFilterProvider = NotifierProvider<PriorityFilterNotifier, IncidentPriority?>(PriorityFilterNotifier.new);

class StatusFilterNotifier extends Notifier<IncidentStatus?> {
  @override
  IncidentStatus? build() => null;
  void set(IncidentStatus? val) => state = val;
}
final statusFilterProvider = NotifierProvider<StatusFilterNotifier, IncidentStatus?>(StatusFilterNotifier.new);
