import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/report.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/earnings_card.dart';
import 'package:car_expenses/widgets/month_switcher.dart';
import 'package:car_expenses/widgets/report_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _now = DateTime.now();

Repair _repair(int minor, Currency c, DateTime date) => Repair(
  id: 'r$minor',
  ownerId: 'u1',
  vehicleId: 'v$minor',
  date: date,
  amountMinor: minor,
  currency: c,
  description: 'service',
);

final _repairs = [
  _repair(12345678, Currency.rsd, _now),
  _repair(98000, Currency.eur, _now),
  _repair(500000, Currency.rsd, DateTime(2020, 1, 1)),
];

/// Spending larger than everything that came in, in both currencies,
/// so the net goes negative.
final _report = Report.of(
  month: _now,
  repairs: _repairs,
  entries: [
    WalletEntry(
      id: 'w',
      type: WalletEntryType.withdrawal,
      amountMinor: 99999999,
      currency: Currency.rsd,
      description: 'x',
      date: _now,
      userId: 'u1',
      createdBy: 'u1',
    ),
  ],
);

/// A narrow phone, so long Serbian labels and amounts must fit.
Future<void> _pump(WidgetTester tester, String lang, Widget child) async {
  tester.view.physicalSize = const Size(360, 1600);
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

void main() {
  setUpAll(initializeDateFormatting);

  for (final lang in ['en', 'sr']) {
    testWidgets('the report fits a phone in $lang', (tester) async {
      await _pump(tester, lang, ReportView(report: _report));
      expect(tester.takeException(), isNull);
      expect(find.text('2'), findsNWidgets(2)); // cars, services
    });

    testWidgets('the services card fits a phone in $lang', (tester) async {
      var opened = false;
      await _pump(
        tester,
        lang,
        EarningsCard(repairs: _repairs, onOpenReport: () => opened = true),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(EarningsCard));
      expect(opened, isTrue);
    });
  }

  testWidgets('the net shows the loss and the month can be stepped', (
    tester,
  ) async {
    DateTime? picked;
    final month = DateTime(2026, 10);
    await _pump(
      tester,
      'en',
      Column(
        children: [
          MonthSwitcher(
            month: month,
            first: DateTime(2026, 9),
            last: month,
            onChanged: (m) => picked = m,
          ),
          ReportView(report: _report),
        ],
      ),
    );
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.textContaining('-'), findsOneWidget); // negative net, RSD

    await tester.tap(find.byTooltip('Next month'));
    expect(picked, isNull);
    await tester.tap(find.byTooltip('Previous month'));
    expect(picked, DateTime(2026, 9));
  });
}
