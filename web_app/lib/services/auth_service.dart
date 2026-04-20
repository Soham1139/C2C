import 'package:firebase_auth/firebase_auth.dart';
import 'audit_log_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuditLogService _auditLogService = AuditLogService();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (result.user != null) {
      await _auditLogService.logAction(
        userId: result.user!.uid,
        action: 'Login',
        module: 'Auth',
      );
    }
    return result;
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _auditLogService.logAction(
        userId: user.uid,
        action: 'Logout',
        module: 'Auth',
      );
    }
    await _auth.signOut();
  }
}
