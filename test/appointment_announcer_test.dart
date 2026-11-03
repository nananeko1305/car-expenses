import 'package:car_expenses/models/appointment.dart';
import 'package:car_expenses/services/appointment_announcer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

final _written = DateTime(2026, 11, 3);

Appointment _booking(
  String id, {
  String owner = 'mika',
  bool? announced = false,
  DateTime? createdAt,
}) => Appointment(
  id: id,
  ownerId: owner,
  date: DateTime(2026, 11, 14),
  text: id,
  createdAt: createdAt ?? _written,
  announced: announced,
);

/// Stands in for LiveData, which opens Firestore as soon as it is made.
class _Calendar extends ChangeNotifier {
  List<Appointment>? bookings;

  void show(List<Appointment> list) {
    bookings = list;
    notifyListeners();
  }
}

void main() {
  late _Calendar calendar;
  late List<String> asked;
  late AppointmentAnnouncer announcer;

  AppointmentAnnouncer make({
    Future<void> Function(String id)? announce,
  }) => AppointmentAnnouncer(
    source: calendar,
    read: () => calendar.bookings,
    uid: 'mika',
    announce:
        announce ??
        (id) async {
          asked.add(id);
        },
  );

  setUp(() {
    calendar = _Calendar();
    asked = [];
    announcer = make();
  });

  test('asks for a booking of mine the server has', () {
    announcer.start();
    calendar.show([_booking('a1')]);
    expect(asked, ['a1']);
  });

  test('picks up what is already there when it starts', () {
    calendar.bookings = [_booking('a1')];
    announcer.start();
    expect(asked, ['a1']);
  });

  test('waits until the calendar has loaded', () {
    announcer.start();
    expect(asked, isEmpty);
    calendar.show(const []);
    expect(asked, isEmpty);
  });

  test('asks once per session, however often the calendar changes', () {
    announcer.start();
    calendar.show([_booking('a1')]);
    calendar.show([_booking('a1')]);
    expect(asked, ['a1']);
  });

  test('a new session asks again, for the worker to sort out', () {
    announcer.start();
    calendar.show([_booking('a1')]);
    announcer.dispose();
    make().start();
    expect(asked, ['a1', 'a1']);
  });

  test('leaves other people\'s bookings to their authors', () {
    announcer.start();
    calendar.show([_booking('a1', owner: 'pera')]);
    expect(asked, isEmpty);
  });

  test('leaves bookings from before pushes alone', () {
    announcer.start();
    calendar.show([_booking('old', announced: null)]);
    expect(asked, isEmpty);
  });

  test('leaves announced bookings alone', () {
    announcer.start();
    calendar.show([_booking('a1', announced: true)]);
    expect(asked, isEmpty);
  });

  test('waits for a booking written offline to reach the server', () {
    announcer.start();
    final offline = Appointment(
      id: 'a1',
      ownerId: 'mika',
      date: DateTime(2026, 11, 14),
      text: 'x',
      announced: false,
    );
    calendar.show([offline]);
    expect(asked, isEmpty);
    calendar.show([_booking('a1')]);
    expect(asked, ['a1']);
  });

  test('a failed call changes nothing and does not retry in a loop', () async {
    var calls = 0;
    announcer = make(
      announce: (id) async {
        calls++;
        throw Exception('offline');
      },
    );
    announcer.start();
    calendar.show([_booking('a1')]);
    await Future<void>.delayed(Duration.zero);
    calendar.show([_booking('a1')]);
    await Future<void>.delayed(Duration.zero);
    expect(calls, 1);
  });

  test('stops listening when disposed', () {
    announcer.start();
    announcer.dispose();
    calendar.show([_booking('a1')]);
    expect(asked, isEmpty);
  });
}
