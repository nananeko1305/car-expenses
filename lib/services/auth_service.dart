import 'package:firebase_auth/firebase_auth.dart';

import 'push_service.dart';

/// Email + password sign-in through Firebase Auth. There is no public
/// registration: accounts are created by the admin (see [UserRepository]).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Firebase requires a recent sign-in to change the password, so the
  /// user confirms the current one first.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// Takes this phone off the account first, but nothing may stand in the
  /// way of signing out: a refused delete would trap an account on the
  /// status screen, and offline the delete never answers.
  Future<void> signOut() async {
    try {
      await PushService.instance.forgetToken().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      // The next sign-in on this phone takes the token over.
    } finally {
      await _auth.signOut();
    }
  }
}
