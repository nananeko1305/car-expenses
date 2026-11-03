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
    this.announced,
  });

  final String id;
  final String ownerId;

  /// Midnight of the booked day.
  final DateTime date;
  final String text;

  /// When it was written; null while that write is still on its way to
  /// the server.
  final DateTime? createdAt;

  /// Whether everyone was told about it: false until the push worker marks
  /// it. Null on bookings from before pushes, which never get one.
  final bool? announced;

  /// The server has it (see [createdAt]) and nobody was told yet.
  bool get awaitsPush => announced == false && createdAt != null;

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

  factory Appointment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Appointment.fromMap(doc.id, doc.data() ?? const {});

  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    return Appointment(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      text: data['text'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      announced: data['announced'] as bool?,
    );
  }

  /// Leaves out `createdAt` and `announced`: the repository sets them once,
  /// on create, and after that only the push worker changes `announced`.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'date': Timestamp.fromDate(_dayOf(date)),
    'text': text,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static DateTime _dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
