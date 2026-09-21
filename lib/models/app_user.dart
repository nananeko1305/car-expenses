import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, user }

/// Profile stored in `users/{uid}`. Decides who may use the app and who
/// may manage other users.
class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.disabled,
    this.firstName = '',
    this.lastName = '',
  });

  final String uid;
  final String email;
  final UserRole role;
  final bool disabled;
  final String firstName;
  final String lastName;

  bool get isAdmin => role == UserRole.admin;

  /// Shared records may be changed only by their author or the admin.
  bool canEdit(String authorId) => isAdmin || uid == authorId;

  /// "First Last", or the email while no name is set.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? email : full;
  }

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
      disabled: data['disabled'] as bool? ?? false,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toNewDocMap() => {
    'email': email,
    'role': role.name,
    'disabled': disabled,
    'firstName': firstName,
    'lastName': lastName,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
