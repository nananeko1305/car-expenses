import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/app_user.dart';
import 'package:car_expenses/models/appointment.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/appointment_dialog.dart';
import 'package:car_expenses/widgets/month_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _oct16 = DateTime(2026, 10, 16);

/// A narrow phone, so the grid must fit seven columns.
Future<void> _pump(WidgetTester tester, String lang, Widget child) async {
  tester.view.physicalSize = const Size(360, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ListView(padding: const EdgeInsets.all(16), children: [child]),
      ),
    ),
  );
}

/// Which column (0-6) a day of the month sits in.
int _column(WidgetTester tester, DateTime day) {
  final grid = tester.getRect(find.byType(MonthGrid));
  final x = tester.getCenter(find.byKey(ValueKey(day))).dx;
  return ((x - grid.left) / (grid.width / 7)).floor();
}

AppUser _user(String uid, {bool admin = false}) => AppUser(
  uid: uid,
  email: '$uid@x.rs',
  role: admin ? UserRole.admin : UserRole.user,
  disabled: false,
);

final _booking = Appointment(
  id: 'a1',
  ownerId: 'mika',
  date: DateTime(2026, 10, 21),
  text: 'Opel Astra, Mika, 10h',
);

void main() {
  setUpAll(initializeDateFormatting);

  group('MonthGrid', () {
    Widget grid({ValueChanged<DateTime>? onSelect}) => MonthGrid(
      month: _oct16,
      selected: _oct16,
      today: _oct16,
      counts: {DateTime(2026, 10, 21): 3},
      onSelect: onSelect ?? (_) {},
    );

    testWidgets('weeks start on Monday in Serbian', (tester) async {
      await _pump(tester, 'sr', grid());
      expect(tester.takeException(), isNull);
      // 1 October 2026 is a Thursday.
      expect(_column(tester, DateTime(2026, 10, 1)), 3);
      expect(_column(tester, DateTime(2026, 10, 31)), 5);
    });

    testWidgets('weeks start on Sunday in English', (tester) async {
      await _pump(tester, 'en', grid());
      expect(tester.takeException(), isNull);
      expect(_column(tester, DateTime(2026, 10, 1)), 4);
    });

    testWidgets('a day shows its bookings and can be picked', (tester) async {
      DateTime? picked;
      await _pump(tester, 'sr', grid(onSelect: (d) => picked = d));
      final day = find.byKey(ValueKey(DateTime(2026, 10, 21)));
      expect(
        find.descendant(of: day, matching: find.text('3')),
        findsOneWidget,
      );
      await tester.tap(day);
      expect(picked, DateTime(2026, 10, 21));
    });
  });

  group('appointment dialog', () {
    Future<void> open(WidgetTester tester, AppUser viewer) async {
      await _pump(
        tester,
        'en',
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showAppointmentDialog(
              context,
              profile: viewer,
              day: _booking.date,
              appointment: _booking,
              authorName: 'Mika Mikić',
            ),
            child: const Text('open'),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Opel Astra, Mika, 10h'), findsOneWidget);
    }

    testWidgets('someone else\'s booking is read-only', (tester) async {
      await open(tester, _user('pera'));
      expect(
        find.text('Only Mika Mikić or the admin can change this.'),
        findsOneWidget,
      );
      expect(find.text('Save'), findsNothing);
      expect(find.byTooltip('Delete'), findsNothing);
      expect(find.text('Close'), findsOneWidget);
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });

    for (final viewer in [_user('mika'), _user('pera', admin: true)]) {
      testWidgets('${viewer.uid} may edit and delete it', (tester) async {
        await open(tester, viewer);
        expect(find.text('Entered by Mika Mikić'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);
        expect(find.byTooltip('Delete'), findsOneWidget);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.enabled, isTrue);
      });
    }
  });
}
