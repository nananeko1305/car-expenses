// The classic interface drawn to PNG files from its real widgets and
// made-up data; see main_screens.dart for what this is and why it is not
// a test.
//
//   flutter test test/shots/classic_screens.dart --update-goldens \
//     --dart-define=OUT=/absolute/folder/for/the/pictures

import 'dart:io';

import 'package:car_expenses/classic/theme/app_palette.dart';
import 'package:car_expenses/classic/theme/app_theme.dart';
import 'package:car_expenses/classic/widgets/balance_card.dart';
import 'package:car_expenses/classic/widgets/earnings_card.dart';
import 'package:car_expenses/classic/widgets/filter_pill.dart';
import 'package:car_expenses/classic/widgets/repair_card.dart';
import 'package:car_expenses/classic/widgets/theme_mode_picker.dart';
import 'package:car_expenses/classic/widgets/ui_style_picker.dart';
import 'package:car_expenses/classic/widgets/wallet_history.dart';
import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/vehicle.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:car_expenses/services/ui_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _out = String.fromEnvironment('OUT');
final _material =
    '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts';

Future<void> _font(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('$_material/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

final _now = DateTime.now();
DateTime _d(int day) => DateTime(_now.year, _now.month, day);

const _golf = Vehicle(
  id: 'g',
  ownerId: 'mika',
  name: 'Golf 5 1.9 TDI',
  plate: 'BG 123-AB',
);

Repair _r(int day, String what, int minor, String who) => Repair(
  id: '$day',
  ownerId: who,
  vehicleId: 'g',
  date: _d(day),
  amountMinor: minor,
  currency: Currency.rsd,
  description: what,
  mileage: 214500,
);

final _repairs = [
  _r(24, 'Mali servis\n- ulje 5W30\n- filteri', 1200000, 'Mika'),
  _r(21, 'Zamena kvačila i zamajca', 5400000, 'Pera'),
  _r(20, 'Mali servis, moj auto', 0, 'Laza'),
];

final _movements = WalletMovement.merge(_repairs, [
  WalletEntry(
    id: 'e',
    type: WalletEntryType.withdrawal,
    amountMinor: 1480000,
    currency: Currency.rsd,
    description: 'Ulje 5W30, kanister 20 l',
    date: _d(23),
    userId: 'Pera',
    createdBy: 'Pera',
  ),
]);

Widget _services(BuildContext context) => Scaffold(
  appBar: AppBar(title: const Text('Servisi')),
  floatingActionButton: FloatingActionButton.extended(
    onPressed: () {},
    icon: const Icon(Icons.add_rounded),
    label: const Text('Novi servis'),
  ),
  body: ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
    children: [
      Row(
        children: [
          Expanded(
            child: FilterPill(
              icon: Icons.directions_car_rounded,
              title: 'Auto',
              allLabel: 'Svi automobili',
              value: null,
              options: const [],
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilterPill(
              icon: Icons.person_rounded,
              title: 'Osoba',
              allLabel: 'Svi',
              value: null,
              options: const [],
              onChanged: (_) {},
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      EarningsCard(repairs: _repairs, onOpenReport: () {}),
      const SizedBox(height: 16),
      for (final r in _repairs) ...[
        RepairCard(
          repair: r,
          vehicle: _golf,
          authorName: r.ownerId,
          onTap: () {},
        ),
        const SizedBox(height: 10),
      ],
    ],
  ),
);

Widget _wallet(BuildContext context) => Scaffold(
  appBar: AppBar(title: const Text('Kasa')),
  body: ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
    children: [
      BalanceCard(
        balances: WalletMovement.balances(_movements),
        showEuros: false,
        onShowEuros: (_) {},
        onAdd: () {},
        onSpend: () {},
      ),
      const SizedBox(height: 8),
      WalletHistory(
        movements: _movements,
        showEuros: false,
        nameOf: (u) => u,
        onTap: (_) {},
      ),
    ],
  ),
);

Widget _settings(BuildContext context) => Scaffold(
  appBar: AppBar(title: const Text('Podešavanja')),
  body: ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Tema',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      ThemeModePicker(value: ThemeMode.system, onChanged: (_) {}),
      const SizedBox(height: 16),
      const Text(
        'Izgled',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 8),
      UiStylePicker(value: UiStyle.classic, onChanged: (_) {}),
    ],
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    await _font('Roboto', [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ]);
    await _font('MaterialIcons', ['MaterialIcons-Regular.otf']);
  });

  Future<void> shot(
    WidgetTester tester,
    String name,
    Widget Function(BuildContext) home, {
    bool dark = false,
  }) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 56);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(kPalettes.first, dark),
        locale: const Locale.fromSubtags(
          languageCode: 'sr',
          scriptCode: 'Latn',
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('sr'),
          Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
        ],
        home: Builder(builder: home),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$_out/$name.png'),
    );
  }

  testWidgets('services', (t) => shot(t, 'classic_servisi', _services));
  testWidgets('wallet', (t) => shot(t, 'classic_kasa', _wallet));
  testWidgets('settings', (t) => shot(t, 'classic_podesavanja', _settings));
}
