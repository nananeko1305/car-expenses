import 'package:car_expenses/classic/theme/app_palette.dart';
import 'package:car_expenses/classic/theme/app_theme.dart';
import 'package:car_expenses/classic/widgets/balance_card.dart';
import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A narrow phone, so long Serbian labels must fit.
Future<void> _pump(
  WidgetTester tester, {
  required Map<Currency, int> balances,
  required bool showEuros,
  ValueChanged<bool>? onShowEuros,
  String lang = 'en',
}) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BalanceCard(
          balances: balances,
          showEuros: showEuros,
          onShowEuros: onShowEuros ?? (_) {},
          onAdd: () {},
          onSpend: () {},
        ),
      ),
    ),
  );
}

const _both = {Currency.rsd: 970000, Currency.eur: 11000};

void main() {
  testWidgets('shows only dinars while the euro switch is off', (tester) async {
    await _pump(tester, balances: _both, showEuros: false);
    expect(find.text('9,700.00 RSD'), findsOneWidget);
    expect(find.textContaining('€'), findsNothing);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('shows euros under the dinars once it is on', (tester) async {
    await _pump(tester, balances: _both, showEuros: true);
    expect(find.text('9,700.00 RSD'), findsOneWidget);
    expect(find.text('110.00 €'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('110.00 €')).dy,
      greaterThan(tester.getTopLeft(find.text('9,700.00 RSD')).dy),
    );
  });

  testWidgets('an empty wallet still shows a zero for each line', (
    tester,
  ) async {
    await _pump(tester, balances: const {}, showEuros: true);
    expect(find.text('0.00 RSD'), findsOneWidget);
    expect(find.text('0.00 €'), findsOneWidget);
  });

  testWidgets('the switch and its label both ask for the other state', (
    tester,
  ) async {
    final asked = <bool>[];
    await _pump(
      tester,
      balances: _both,
      showEuros: false,
      onShowEuros: asked.add,
    );
    await tester.tap(find.byType(Switch));
    await tester.tap(find.text('Euros'));
    expect(asked, [true, true]);

    asked.clear();
    await _pump(
      tester,
      balances: _both,
      showEuros: true,
      onShowEuros: asked.add,
    );
    await tester.tap(find.text('Euros'));
    expect(asked, [false]);
  });

  testWidgets('fits Serbian labels and both currencies on a narrow phone', (
    tester,
  ) async {
    await _pump(
      tester,
      balances: const {Currency.rsd: 123456789000, Currency.eur: 98765400},
      showEuros: true,
      lang: 'sr',
    );
    expect(find.text('Evri'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
