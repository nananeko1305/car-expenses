import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/repair.dart';

/// CRUD for services. Everyone reads all of them; rules let only the
/// author (or the admin) change or delete one.
class RepairRepository {
  RepairRepository._();
  static final RepairRepository instance = RepairRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _repairs =>
      _db.collection('repairs');

  /// All services, newest first.
  Stream<List<Repair>> watchAll() => _repairs
      .orderBy('date', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map(Repair.fromDoc).toList());

  Future<void> save(Repair repair) {
    if (repair.id.isEmpty) {
      return _repairs.add({
        ...repair.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _repairs.doc(repair.id).update(repair.toMap());
  }

  Future<void> delete(String id) => _repairs.doc(id).delete();
}
