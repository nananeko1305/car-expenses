import 'package:cloud_firestore/cloud_firestore.dart';

/// Something booked for a day, stored in `appointments/{id}`: free text
/// such as "Opel Astra, Mika, 10h". Everyone sees it; only [ownerId]
/// (who wrote it) or the admin may change it.
class Appointment {
  const Appointment({
    required this.id,
    required this.ownerId,
    required this.date,
    required this.text,
    this.createdAt,
  });

  final String id;
  final String ownerId;

  /// Midnight of the booked day.
  final DateTime date;
  final String text;

  /// When it was written; null while that write is still on its way to
  /// the server.
  final DateTime? createdAt;

  /// The last day a booking can go on: the end of next year.
  static DateTime lastBookable(DateTime now) => DateTime(now.year + 1, 12, 31);

  /// Bookings per day (midnight), each day in the order they were
  /// written; one still being saved goes last.
  static Map<DateTime, List<Appointment>> byDay(List<Appointment> all) {
    final days = <DateTime, List<Appointment>>{};
    for (final a in all) {
      final day = _dayOf(a.date);
      (days[day] ??= []).add(a);
    }
    for (final list in days.values) {
      list.sort((a, b) {
        if (a.createdAt == null) return b.createdAt == null ? 0 : 1;
        if (b.createdAt == null) return -1;
        return a.createdAt!.compareTo(b.createdAt!);
      });
    }
    return days;
  }

  factory Appointment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Appointment(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Leaves out `createdAt`: the repository sets it once, on create.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'date': Timestamp.fromDate(_dayOf(date)),
    'text': text,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
