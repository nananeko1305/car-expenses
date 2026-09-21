import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/vehicle.dart';

/// CRUD for the shared list of cars.
class VehicleRepository {
  VehicleRepository._();
  static final VehicleRepository instance = VehicleRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vehicles =>
      _db.collection('vehicles');

  Stream<List<Vehicle>> watchAll() => _vehicles.snapshots().map((snap) {
    final list = snap.docs.map(Vehicle.fromDoc).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  });

  Future<void> save(Vehicle vehicle) {
    if (vehicle.id.isEmpty) {
      return _vehicles.add({
        ...vehicle.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _vehicles.doc(vehicle.id).update(vehicle.toMap());
  }

  /// A car with services cannot be deleted: those services belong to
  /// other people too, so they are never removed as a side effect.
  Future<bool> hasRepairs(String vehicleId) async {
    final snap = await _db
        .collection('repairs')
        .where('vehicleId', isEqualTo: vehicleId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> delete(String id) => _vehicles.doc(id).delete();
}
