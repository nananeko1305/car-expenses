import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/appointment_push.dart';
import 'package:car_expenses/widgets/appointment_push_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _show(WidgetTester tester, AppointmentPush push, String lang) {
  return tester
      .pumpWidget(
        MaterialApp(
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  appointmentPushSnackBar(AppLocalizations.of(context), push),
                ),
                child: const Text('show'),
              ),
            ),
          ),
        ),
      )
      .then((_) => tester.tap(find.text('show')))
      .then((_) => tester.pumpAndSettle());
}

void main() {
  group('reading a push', () {
    test('a new booking', () {
      final push = AppointmentPush.fromMessage({
        'type': 'appointment',
        'day': '2026-11-14',
      }, 'Opel Astra, Mika, 10h')!;
      expect(push.kind, AppointmentPushKind.booking);
      expect(push.day, DateTime(2026, 11, 14));
      expect(push.body, 'Opel Astra, Mika, 10h');
    });

    test('a reminder', () {
      final push = AppointmentPush.fromMessage({
        'type': 'reminder',
        'day': '2026-11-14',
      }, 'a\nb')!;
      expect(push.kind, AppointmentPushKind.reminder);
    });

    test('a cancelled booking', () {
      final push = AppointmentPush.fromMessage({
        'type': 'cancelled',
        'day': '2026-11-14',
      }, 'Opel Astra, Mika, 10h')!;
      expect(push.kind, AppointmentPushKind.cancelled);
      expect(push.day, DateTime(2026, 11, 14));
      expect(push.body, 'Opel Astra, Mika, 10h');
    });

    test('the date as the title shows it, without leading zeros', () {
      final push = AppointmentPush.fromMessage({
        'type': 'reminder',
        'day': '2027-01-05',
      }, '')!;
      expect(push.dateLabel, '5.1.2027.');
    });

    test('anything else is not a calendar push', () {
      expect(
        AppointmentPush.fromMessage({'type': 'release', 'version': '1.2.0'}, ''),
        isNull,
      );
      expect(AppointmentPush.fromMessage(const {}, 'x'), isNull);
      expect(
        AppointmentPush.fromMessage({'type': 'appointment'}, 'x'),
        isNull,
      );
      expect(
        AppointmentPush.fromMessage({'type': 'reminder', 'day': 'soon'}, 'x'),
        isNull,
      );
    });
  });

  group('the snack bar', () {
    final booking = AppointmentPush(
      kind: AppointmentPushKind.booking,
      day: DateTime(2026, 11, 14),
      body: 'Opel Astra, Mika, 10h',
    );

    testWidgets('names a new booking in Serbian', (tester) async {
      await _show(tester, booking, 'sr');
      expect(find.text('Novo zakazivanje za 14.11.2026.'), findsOneWidget);
      expect(find.text('Opel Astra, Mika, 10h'), findsOneWidget);
    });

    testWidgets('names a new booking in English', (tester) async {
      await _show(tester, booking, 'en');
      expect(find.text('New booking for 14.11.2026.'), findsOneWidget);
    });

    testWidgets('names a reminder', (tester) async {
      final reminder = AppointmentPush(
        kind: AppointmentPushKind.reminder,
        day: DateTime(2026, 11, 14),
        body: 'a\nb',
      );
      await _show(tester, reminder, 'sr');
      expect(find.text('Sutra je zakazano, 14.11.2026.'), findsOneWidget);
    });

    final cancelled = AppointmentPush(
      kind: AppointmentPushKind.cancelled,
      day: DateTime(2026, 11, 14),
      body: 'Opel Astra, Mika, 10h',
    );

    testWidgets('names a cancelled booking in Serbian', (tester) async {
      await _show(tester, cancelled, 'sr');
      expect(find.text('Oslobođen termin za 14.11.2026.'), findsOneWidget);
      expect(find.text('Opel Astra, Mika, 10h'), findsOneWidget);
    });

    testWidgets('names a cancelled booking in English', (tester) async {
      await _show(tester, cancelled, 'en');
      expect(find.text('Booking cancelled for 14.11.2026.'), findsOneWidget);
    });

    testWidgets('a long reminder does not overflow a narrow phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final long = AppointmentPush(
        kind: AppointmentPushKind.reminder,
        day: DateTime(2026, 11, 14),
        body: List.filled(20, 'Opel Astra, Mika, 10h').join('\n'),
      );
      await _show(tester, long, 'sr');
      expect(tester.takeException(), isNull);
    });
  });
}
