import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/tool.dart';
import 'package:car_expenses/models/warranty.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/warranty_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _tool = Tool(
  id: 't1',
  ownerId: 'u1',
  name: 'Udarni odvijač',
  purchaseDate: DateTime(2026, 1, 1),
  warrantyAmount: 1,
  warrantyUnit: WarrantyUnit.years,
);

Future<double> _pumpAt(WidgetTester tester, DateTime now) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WarrantyBar(tool: _tool, now: now),
      ),
    ),
  );
  return tester
      .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .value!;
}

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('the bar fills as the warranty runs out', (tester) async {
    expect(await _pumpAt(tester, DateTime(2026, 1, 1)), 0);
    expect(find.textContaining('Warranty until'), findsOneWidget);

    expect(await _pumpAt(tester, DateTime(2026, 7, 1)), closeTo(0.5, 0.01));

    expect(await _pumpAt(tester, DateTime(2026, 12, 20)), closeTo(0.97, 0.01));
    expect(find.text('12 days left'), findsOneWidget);

    expect(await _pumpAt(tester, DateTime(2027, 1, 1)), 1);
    expect(find.text('Warranty ends today'), findsOneWidget);
  });

  // A progress bar asserts on a value outside [0, 1], so a tool dated in
  // the future or long expired must not take the list down with it.
  testWidgets('an out-of-range date still renders', (tester) async {
    expect(await _pumpAt(tester, DateTime(2030, 1, 1)), 1);
    expect(find.text('Warranty expired'), findsOneWidget);

    expect(await _pumpAt(tester, DateTime(2020, 1, 1)), 0);
  });
}
