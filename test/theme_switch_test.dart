import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/repair_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _repair = Repair(
  id: 'r1',
  ownerId: 'u1',
  performedBy: 'u1',
  vehicleId: 'v1',
  date: DateTime(2026, 9, 21),
  amountMinor: 1500000,
  currency: Currency.rsd,
  description: 'Mali servis',
);

Widget _app(bool dark) => MaterialApp(
  theme: AppTheme.build(kPalettes.first, dark),
  home: Scaffold(
    body: RepairCard(
      repair: _repair,
      vehicle: null,
      personName: 'Petar Petrović',
      onTap: () {},
    ),
  ),
);

Color _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style!.color!;

void main() {
  setUpAll(initializeDateFormatting);

  // Regression: secondary text kept its light-mode color after switching
  // to dark mode, because colors were read from static getters.
  testWidgets('secondary text follows a live light -> dark switch', (
    tester,
  ) async {
    await tester.pumpWidget(_app(false));
    final light = _colorOf(tester, 'Petar Petrović');

    await tester.pumpWidget(_app(true));
    await tester.pumpAndSettle();
    final dark = _colorOf(tester, 'Petar Petrović');

    expect(dark, isNot(light));
    // Light text on a dark background.
    expect(dark.computeLuminance(), greaterThan(0.5));
  });
}
