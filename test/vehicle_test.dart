import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/vehicle.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/vehicle_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const golf = Vehicle(
    id: '1',
    ownerId: 'u',
    name: 'VW Golf',
    plate: 'BG-123-AB',
    vin: 'WVWZZZ1KZ8W123456',
  );
  const skoda = Vehicle(
    id: '2',
    ownerId: 'u',
    name: 'Škoda',
    plate: 'NI 045-ŠĐ',
  );

  test('plate search ignores case, spaces and dashes', () {
    for (final q in ['bg123ab', 'BG-123', ' 123 ab', '123-AB', '']) {
      expect(golf.matches(q), isTrue, reason: q);
    }
    expect(golf.matches('NI'), isFalse);
  });

  test('Serbian letters in plates are matched', () {
    expect(skoda.matches('045šđ'), isTrue);
    expect(skoda.matches('ni045'), isTrue);
  });

  test('name matches too', () {
    expect(golf.matches('golf'), isTrue);
    expect(skoda.matches('škoda'), isTrue);
  });

  group('VIN', () {
    test('is tidied to upper case without spaces or dashes', () {
      expect(
        Vehicle.normalizeVin(' wvwzzz 1kz8-w123456 '),
        'WVWZZZ1KZ8W123456',
      );
    });

    test('must be 17 letters and digits, without I, O or Q', () {
      expect(Vehicle.isValidVin('WVWZZZ1KZ8W123456'), isTrue);
      expect(Vehicle.isValidVin('WVWZZZ1KZ8W12345'), isFalse); // 16
      expect(Vehicle.isValidVin('WVWZZZ1KZ8W1234567'), isFalse); // 18
      expect(Vehicle.isValidVin('WVWZZZ1KZ8WO23456'), isFalse); // O
      expect(Vehicle.isValidVin('WVWZZZ1KZ8WI23456'), isFalse); // I
      expect(Vehicle.isValidVin('WVWZZZ1KZ8WQ23456'), isFalse); // Q
      expect(Vehicle.isValidVin(''), isFalse);
    });

    test('search finds a car by part of its VIN, from four characters', () {
      expect(golf.matches('123456'), isTrue);
      expect(golf.matches('w123'), isTrue);
      expect(golf.matches('kz8'), isFalse); // too short to look in the VIN
      expect(skoda.matches('123456'), isFalse); // no VIN
    });
  });

  group('car dialog', () {
    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(kPalettes.first, false),
          locale: const Locale('sr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showVehicleDialog(context, ownerId: 'u'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('asks for the VIN and recommends it', (tester) async {
      await open(tester);
      expect(find.text('Broj šasije (VIN)'), findsOneWidget);
      expect(
        find.text('Preporučeno. Sa saobraćajne dozvole, polje E.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('refuses a VIN that is not whole', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'VW Golf');
      await tester.enterText(find.byType(TextFormField).at(2), 'WVWZZZ1KZ8');
      await tester.tap(find.text('Sačuvaj'));
      await tester.pump();
      expect(
        find.text('Broj šasije ima 17 slova i brojeva, bez I, O i Q'),
        findsOneWidget,
      );
    });
  });
}
