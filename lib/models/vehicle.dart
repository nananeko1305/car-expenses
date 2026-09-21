import 'package:cloud_firestore/cloud_firestore.dart';

/// A car owned by one user, stored in `vehicles/{id}`.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.plate,
  });

  final String id;
  final String ownerId;

  /// Make and model, e.g. "Škoda Octavia".
  final String name;
  final String plate;

  String get label => plate.isEmpty ? name : '$name · $plate';

  /// True when [query] matches the plate (ignoring spaces, dashes and
  /// case, so "bg123ab" finds "BG-123-AB") or part of the name.
  bool matches(String query) {
    final q = normalizePlate(query);
    if (q.isEmpty) return true;
    return normalizePlate(plate).contains(q) ||
        name.toLowerCase().contains(query.trim().toLowerCase());
  }

  /// Uppercase letters and digits only, Serbian letters included.
  static String normalizePlate(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9ČĆŽŠĐ]'), '');

  factory Vehicle.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Vehicle(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      plate: data['plate'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'plate': plate,
  };
}
