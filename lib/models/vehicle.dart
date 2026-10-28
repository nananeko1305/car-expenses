import 'package:cloud_firestore/cloud_firestore.dart';

/// A car owned by one user, stored in `vehicles/{id}`.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.plate,
    this.vin = '',
  });

  final String id;
  final String ownerId;

  /// Make and model, e.g. "Škoda Octavia".
  final String name;
  final String plate;

  /// Chassis number (VIN), tidied by [normalizeVin]; empty when not
  /// entered. Optional, but what parts are ordered by.
  final String vin;

  String get label => plate.isEmpty ? name : '$name · $plate';

  /// True when [query] matches the plate (ignoring spaces, dashes and
  /// case, so "bg123ab" finds "BG-123-AB"), part of the name, or part of
  /// the VIN. The VIN needs at least four characters: a shorter query
  /// would turn up nearly every car.
  bool matches(String query) {
    final q = normalizePlate(query);
    if (q.isEmpty) return true;
    return normalizePlate(plate).contains(q) ||
        name.toLowerCase().contains(query.trim().toLowerCase()) ||
        (q.length >= 4 && vin.contains(q));
  }

  /// A VIN as typed, tidied: upper case, without spaces or dashes.
  static String normalizeVin(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

  /// Whether [vin] (already normalized) is a standard VIN: 17 letters
  /// and digits, never I, O or Q, which VINs leave out so they are not
  /// read as 1 and 0.
  static bool isValidVin(String vin) =>
      RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(vin);

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
      vin: data['vin'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'plate': plate,
    'vin': vin,
  };
}
