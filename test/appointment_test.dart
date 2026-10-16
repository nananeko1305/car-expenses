import 'package:car_expenses/models/appointment.dart';
import 'package:flutter_test/flutter_test.dart';

Appointment _a(String id, DateTime date, [DateTime? createdAt]) => Appointment(
  id: id,
  ownerId: 'u1',
  date: date,
  text: id,
  createdAt: createdAt,
);

void main() {
  test('bookings group by day, whatever the time on the date', () {
    final days = Appointment.byDay([
      _a('a', DateTime(2026, 10, 21)),
      _a('b', DateTime(2026, 10, 21, 23, 59)),
      _a('c', DateTime(2026, 10, 22)),
    ]);
    expect(days.keys, [DateTime(2026, 10, 21), DateTime(2026, 10, 22)]);
    expect(days[DateTime(2026, 10, 21)]!.map((a) => a.id), ['a', 'b']);
  });

  test('a day lists bookings as written, one still saving last', () {
    final day = DateTime(2026, 10, 21);
    final days = Appointment.byDay([
      _a('saving', day),
      _a('second', day, DateTime(2026, 10, 2, 9)),
      _a('first', day, DateTime(2026, 10, 1, 18)),
    ]);
    expect(days[day]!.map((a) => a.id), ['first', 'second', 'saving']);
  });

  test('bookings can go up to the end of next year', () {
    expect(
      Appointment.lastBookable(DateTime(2026, 10, 16)),
      DateTime(2027, 12, 31),
    );
    expect(
      Appointment.lastBookable(DateTime(2026, 1, 1)),
      DateTime(2027, 12, 31),
    );
  });
}
