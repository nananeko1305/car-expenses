import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/appointment.dart';

/// CRUD for the calendar. Everyone reads all of it; rules let only the
/// author (or the admin) change or delete a booking.
class AppointmentRepository {
  AppointmentRepository._();
  static final AppointmentRepository instance = AppointmentRepository._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');

  /// Every booking, by day.
  Stream<List<Appointment>> watchAll() => _appointments
      .orderBy('date')
      .snapshots()
      .map((snap) => snap.docs.map(Appointment.fromDoc).toList());

  Future<void> save(Appointment appointment) {
    if (appointment.id.isEmpty) {
      return _appointments.add({
        ...appointment.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return _appointments.doc(appointment.id).update(appointment.toMap());
  }

  Future<void> delete(String id) => _appointments.doc(id).delete();
}
