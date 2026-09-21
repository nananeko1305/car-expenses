import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> signOut() => _auth.signOut();
}
