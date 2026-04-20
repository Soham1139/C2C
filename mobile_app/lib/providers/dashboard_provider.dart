import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/incident_model.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class DashboardFilters {
  final IncidentPriority? priority;
  final IncidentStatus? status;

  DashboardFilters({this.priority, this.status});

  DashboardFilters copyWith({
    IncidentPriority? priority,
    IncidentStatus? status,
    bool clearPriority = false,
    bool clearStatus = false,
  }) {
    return DashboardFilters(
      priority: clearPriority ? null : (priority ?? this.priority),
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

class DashboardFilterNotifier extends Notifier<DashboardFilters> {
  @override
  DashboardFilters build() => DashboardFilters();

  void update(DashboardFilters filters) {
    state = filters;
  }
}

final dashboardFilterProvider = NotifierProvider<DashboardFilterNotifier, DashboardFilters>(() {
  return DashboardFilterNotifier();
});

final incidentStreamProvider = StreamProvider<List<IncidentModel>>((ref) {
  final filters = ref.watch(dashboardFilterProvider);
  return ref.read(firestoreServiceProvider).getIncidents(
    priority: filters.priority,
    status: filters.status,
  );
});

class DashboardController extends AsyncNotifier<void> {
  late final FirestoreService _firestoreService;

  @override
  FutureOr<void> build() {
    _firestoreService = ref.read(firestoreServiceProvider);
  }

  Future<void> updateStatus(String id, IncidentStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.updateIncidentStatus(id, status));
  }

  Future<void> deleteIncident(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _firestoreService.deleteIncident(id));
  }
}

final dashboardControllerProvider = AsyncNotifierProvider<DashboardController, void>(() {
  return DashboardController();
});
