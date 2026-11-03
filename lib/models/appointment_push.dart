/// A calendar push as the app reads it: a new booking, or the evening
/// reminder of tomorrow's bookings.
class AppointmentPush {
  const AppointmentPush({
    required this.isReminder,
    required this.day,
    required this.body,
  });

  final bool isReminder;

  /// Midnight of the booked day.
  final DateTime day;

  /// The text of the booking, or of a day's bookings.
  final String body;

  /// "14.11.2026.", as the notification's title shows it.
  String get dateLabel => '${day.day}.${day.month}.${day.year}.';

  /// Null for anything else, such as a release push. The push worker sends
  /// the title as a string resource, so only [data] says what this is.
  static AppointmentPush? fromMessage(Map<String, dynamic> data, String? body) {
    final type = data['type'];
    if (type != 'appointment' && type != 'reminder') return null;
    final day = DateTime.tryParse(data['day'] as String? ?? '');
    if (day == null) return null;
    return AppointmentPush(
      isReminder: type == 'reminder',
      day: day,
      body: body ?? '',
    );
  }
}
