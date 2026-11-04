/// What a calendar push is about.
enum AppointmentPushKind { booking, reminder, cancelled }

/// A calendar push as the app reads it: a new booking, a cancelled one, or
/// the evening reminder of tomorrow's bookings.
class AppointmentPush {
  const AppointmentPush({
    required this.kind,
    required this.day,
    required this.body,
  });

  final AppointmentPushKind kind;

  /// Midnight of the booked day.
  final DateTime day;

  /// The text of the booking, or of a day's bookings.
  final String body;

  /// "14.11.2026.", as the notification's title shows it.
  String get dateLabel => '${day.day}.${day.month}.${day.year}.';

  static const _kinds = {
    'appointment': AppointmentPushKind.booking,
    'reminder': AppointmentPushKind.reminder,
    'cancelled': AppointmentPushKind.cancelled,
  };

  /// Null for anything else, such as a release push. The push worker sends
  /// the title as a string resource, so only [data] says what this is.
  static AppointmentPush? fromMessage(Map<String, dynamic> data, String? body) {
    final kind = _kinds[data['type']];
    if (kind == null) return null;
    final day = DateTime.tryParse(data['day'] as String? ?? '');
    if (day == null) return null;
    return AppointmentPush(kind: kind, day: day, body: body ?? '');
  }
}
