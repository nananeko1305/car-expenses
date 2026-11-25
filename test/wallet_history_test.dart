import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/month_switcher.dart';
import 'package:car_expenses/widgets/wallet_history.dart';
import 'package:car_expenses/widgets/wallet_month_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _now = DateTime.now();

/// The tenth of the month [back] months before this one.
DateTime _monthsAgo(int back) => DateTime(_now.year, _now.month - back, 10);

WalletEntry _spent(
  String what,
  DateTime date, {
  int minor = 150000,
  Currency c = Currency.rsd,
  WalletEntryType type = WalletEntryType.withdrawal,
}) => WalletEntry(
  id: what,
  type: type,
  amountMinor: minor,
  currency: c,
  description: what,
  date: date,
  userId: 'mika',
  createdBy: 'mika',
);

Repair _service(String what, DateTime date) => Repair(
  id: what,
  ownerId: 'pera',
  vehicleId: 'v1',
  date: date,
  amountMinor: 900000,
  currency: Currency.rsd,
  description: what,
);

/// Oil this month, brake pads last month, and a service three months ago,
/// which leaves the month before last empty.
final _movements = WalletMovement.merge(
  [_service('Veliki servis', _monthsAgo(3))],
  [_spent('Ulje', _now), _spent('Plocice', _monthsAgo(1))],
);

/// A narrow phone, so long Serbian labels must fit.
Future<void> _pump(
  WidgetTester tester,
  List<WalletMovement> movements, {
  String lang = 'en',
  bool showEuros = false,
  ValueChanged<WalletMovement>? onTap,
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
        body: ListView(
          children: [
            WalletHistory(
              movements: movements,
              showEuros: showEuros,
              nameOf: (uid) => uid == 'mika' ? 'Mika' : 'Pera',
              onTap: onTap ?? (_) {},
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _back(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Previous month'));
  await tester.pump();
}

/// The amounts the month's summary shows next to [label].
Iterable<String?> _sums(WidgetTester tester, String label) {
  final row = find.ancestor(
    of: find.descendant(
      of: find.byType(WalletMonthSummary),
      matching: find.text(label),
    ),
    matching: find.byType(Row),
  );
  return tester
      .widgetList<Text>(
        find.descendant(of: row.first, matching: find.byType(Text)),
      )
      .map((text) => text.data)
      .where((text) => text != label);
}

bool _enabled(WidgetTester tester, String tooltip) =>
    tester
        .widget<IconButton>(
          find.ancestor(
            of: find.byTooltip(tooltip),
            matching: find.byType(IconButton),
          ),
        )
        .onPressed !=
    null;

void main() {
  setUpAll(initializeDateFormatting);

  testWidgets('starts at this month and leaves the earlier ones out', (
    tester,
  ) async {
    await _pump(tester, _movements);
    expect(find.text('Ulje'), findsOneWidget);
    expect(find.text('Plocice'), findsNothing);
    expect(find.text('Veliki servis'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the arrow back shows the month before, and only that', (
    tester,
  ) async {
    await _pump(tester, _movements);
    await _back(tester);
    expect(find.text('Plocice'), findsOneWidget);
    expect(find.text('Ulje'), findsNothing);
    expect(find.text('Veliki servis'), findsNothing);
  });

  testWidgets('a month nothing happened in says so', (tester) async {
    await _pump(tester, _movements);
    await _back(tester);
    await _back(tester);
    expect(find.text('No wallet movements in this month.'), findsOneWidget);
    expect(find.text('Plocice'), findsNothing);
  });

  testWidgets('stops at the oldest movement and at the current month', (
    tester,
  ) async {
    await _pump(tester, _movements);
    expect(_enabled(tester, 'Next month'), isFalse);
    expect(_enabled(tester, 'Previous month'), isTrue);

    for (var i = 0; i < 3; i++) {
      await _back(tester);
    }
    expect(find.text('Veliki servis'), findsOneWidget);
    expect(_enabled(tester, 'Previous month'), isFalse);
    expect(_enabled(tester, 'Next month'), isTrue);
  });

  group('the month\'s sums', () {
    // This month: a 9.000 service and a 2.000 deposit in, 1.500 out, and
    // 50 euros out. Last month: 700 out.
    final busy = WalletMovement.merge(
      [_service('Servis', _now)],
      [
        _spent('Uplata', _now, minor: 200000, type: WalletEntryType.deposit),
        _spent('Ulje', _now),
        _spent('Kirija', _now, minor: 5000, c: Currency.eur),
        _spent('Plocice', _monthsAgo(1), minor: 70000),
      ],
    );

    testWidgets('add up what came in, what was spent and what is left', (
      tester,
    ) async {
      await _pump(tester, busy);
      expect(_sums(tester, 'Came in'), ['11,000.00 RSD']);
      expect(_sums(tester, 'Spent'), ['− 1,500.00 RSD']);
      expect(_sums(tester, 'Earned'), ['9,500.00 RSD']);
    });

    testWidgets('follow the month that is shown', (tester) async {
      await _pump(tester, busy);
      await _back(tester);
      expect(_sums(tester, 'Came in'), ['0.00 RSD']);
      expect(_sums(tester, 'Spent'), ['− 700.00 RSD']);
      expect(_sums(tester, 'Earned'), ['-700.00 RSD']);
    });

    testWidgets('list euros only when asked to', (tester) async {
      await _pump(tester, busy, showEuros: true);
      expect(_sums(tester, 'Came in'), ['11,000.00 RSD', '0.00 €']);
      expect(_sums(tester, 'Spent'), ['− 1,500.00 RSD', '− 50.00 €']);
      expect(_sums(tester, 'Earned'), ['9,500.00 RSD', '-50.00 €']);

      // The euro movement itself stays on the list either way.
      await _pump(tester, busy);
      expect(find.text('Kirija'), findsOneWidget);
      expect(find.textContaining('€'), findsOneWidget);
    });

    testWidgets('put no minus before a zero', (tester) async {
      await _pump(tester, busy, showEuros: true);
      await _back(tester);
      expect(_sums(tester, 'Spent'), ['− 700.00 RSD', '0.00 €']);
    });

    testWidgets('are left out of a month nothing happened in', (tester) async {
      await _pump(tester, _movements);
      expect(find.byType(WalletMonthSummary), findsOneWidget);
      await _back(tester);
      await _back(tester);
      expect(find.byType(WalletMonthSummary), findsNothing);
    });
  });

  testWidgets('keeps the chosen month when the wallet changes', (tester) async {
    await _pump(tester, _movements);
    await _back(tester);
    await _pump(
      tester,
      WalletMovement.merge(const [], [
        _spent('Plocice', _monthsAgo(1)),
        _spent('Filter', _monthsAgo(1)),
        _spent('Ulje', _now),
      ]),
    );
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Ulje'), findsNothing);
  });

  testWidgets('an empty wallet says so and offers no months', (tester) async {
    await _pump(tester, const [], lang: 'sr');
    expect(find.text('Još nema promena u kasi.'), findsOneWidget);
    expect(find.byType(MonthSwitcher), findsNothing);
  });

  testWidgets('hands over the movement that was tapped', (tester) async {
    WalletMovement? tapped;
    await _pump(tester, _movements, onTap: (m) => tapped = m);
    await tester.tap(find.text('Ulje'));
    expect(tapped?.entry?.id, 'Ulje');
  });

  testWidgets('fits Serbian text on a narrow phone, in every month', (
    tester,
  ) async {
    final long = WalletMovement.merge(const [], [
      _spent('Pneumatski udarni odvijač sa nastavcima ' * 3, _now),
      _spent('Kočione pločice', _monthsAgo(2)),
    ]);
    await _pump(tester, long, lang: 'sr');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Prethodni mesec'));
    await tester.pump();
    expect(
      find.text('U ovom mesecu nije bilo promena u kasi.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
