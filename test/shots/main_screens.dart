// Draws the app's screens to PNG files, from the real widgets and made-up
// data, so a change of look can be seen without a phone and without
// anyone's real records. The name does not end in _test.dart on purpose:
// `flutter test` leaves it alone, and it is run by hand.
//
//   flutter test test/shots/main_screens.dart --update-goldens \
//     --dart-define=OUT=/absolute/folder/for/the/pictures
//
// Shadows come out as dark outlines: that is how Flutter draws them in
// tests, not how they look on a phone.

import 'dart:io';

import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/app_user.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/vehicle.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:car_expenses/screens/more_tab.dart';
import 'package:car_expenses/theme/app_colors.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/balance_card.dart';
import 'package:car_expenses/widgets/date_field.dart';
import 'package:car_expenses/widgets/earnings_card.dart';
import 'package:car_expenses/widgets/filter_pill.dart';
import 'package:car_expenses/widgets/race_nav_bar.dart';
import 'package:car_expenses/widgets/repair_card.dart';
import 'package:car_expenses/widgets/repair_price_fields.dart';
import 'package:car_expenses/widgets/skewed.dart';
import 'package:car_expenses/widgets/slant_header.dart';
import 'package:car_expenses/widgets/wallet_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _out = String.fromEnvironment('OUT');
final _material =
    '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/material_fonts';

Future<void> _font(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final bytes = File(p).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

final _now = DateTime.now();
DateTime _d(int day) => DateTime(_now.year, _now.month, day);

Vehicle _car(String id, String name, String plate) =>
    Vehicle(id: id, ownerId: 'mika', name: name, plate: plate);

final _cars = {
  'g': _car('g', 'Golf 5 1.9 TDI', 'BG 123-AB'),
  'a': _car('a', 'Astra H', 'NS 456-CD'),
  'o': _car('o', 'Octavia', 'NI 789-EF'),
  'p': _car('p', 'Punto', 'KG 012-GH'),
  'b': _car('b', 'Passat B6', 'SU 345-IJ'),
  'f': _car('f', 'Focus', 'BG 678-KL'),
  'm': _car('m', 'Megane', 'NS 901-MN'),
};

Repair _r(String car, int day, String what, int minor, String who, int km) =>
    Repair(
      id: '$car$day',
      ownerId: who,
      vehicleId: car,
      date: _d(day),
      amountMinor: minor,
      currency: Currency.rsd,
      description: what,
      mileage: km,
    );

final _repairs = [
  _r('g', 24, 'Mali servis\n- ulje 5W30\n- filteri', 1200000, 'Mika', 214500),
  _r('a', 23, 'Zadnje pločice i diskovi', 1850000, 'Pera', 187300),
  _r('o', 21, 'Zamena kvačila i zamajca', 5400000, 'Mika', 256900),
  _r('p', 20, 'Mali servis, moj auto', 0, 'Laza', 142800),
  _r('b', 18, 'Zupčasti kaiš i vodena pumpa', 3800000, 'Pera', 231100),
  _r('f', 17, 'Prednji amortizeri, par', 2750000, 'Mika', 198400),
  _r('m', 14, 'Dijagnostika i brisanje grešaka', 300000, 'Laza', 176000),
];

WalletEntry _e(
  String what,
  WalletEntryType type,
  int minor,
  int day,
  String who, [
  Currency c = Currency.rsd,
]) => WalletEntry(
  id: what,
  type: type,
  amountMinor: minor,
  currency: c,
  description: what,
  date: _d(day),
  userId: who,
  createdBy: who,
);

final _movements = WalletMovement.merge(_repairs, [
  _e(
    'Ulje 5W30, kanister 20 l',
    WalletEntryType.withdrawal,
    1480000,
    23,
    'Pera',
  ),
  _e('Keš iz kancelarije', WalletEntryType.deposit, 2000000, 22, 'Laza'),
  _e('Kirija za novembar', WalletEntryType.withdrawal, 4500000, 20, 'Mika'),
  _e(
    'Avans u evrima',
    WalletEntryType.deposit,
    15000,
    19,
    'Mika',
    Currency.eur,
  ),
]);

List<RaceNavItem> get _nav => [
  (icon: Icons.build_rounded, label: 'Servisi'),
  (icon: Icons.account_balance_wallet_rounded, label: 'Kasa'),
  (icon: Icons.calendar_month_rounded, label: 'Kalendar'),
  (icon: Icons.menu_rounded, label: 'Više'),
];

Widget _services(BuildContext context) => Scaffold(
  bottomNavigationBar: RaceNavBar(items: _nav, index: 0, onChanged: (_) {}),
  floatingActionButton: SkewButton(
    label: 'Novi servis',
    icon: Icons.add_rounded,
    height: 50,
    fontSize: 16,
    elevation: 4,
    onPressed: () {},
  ),
  body: Column(
    children: [
      SlantHeader(
        title: 'Servisi',
        subtitle: 'novembar 2026.',
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
        ],
        child: EarningsCard(repairs: _repairs, onOpenReport: () {}),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 22, 8),
        child: Row(
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
            const SizedBox(width: 12),
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
      ),
      Divider(height: 1, color: context.colors.line),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final r in _repairs)
              RepairCard(
                repair: r,
                vehicle: _cars[r.vehicleId],
                authorName: r.ownerId,
                onTap: () {},
              ),
          ],
        ),
      ),
    ],
  ),
);

class _Wallet extends StatefulWidget {
  const _Wallet();
  @override
  State<_Wallet> createState() => _WalletState();
}

class _WalletState extends State<_Wallet> {
  bool _euros = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: RaceNavBar(items: _nav, index: 1, onChanged: (_) {}),
    body: Column(
      children: [
        SlantHeader(
          title: 'Kasa',
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded),
              onPressed: () {},
            ),
          ],
          child: BalanceCard(
            balances: WalletMovement.balances(_movements),
            showEuros: _euros,
            onShowEuros: (v) => setState(() => _euros = v),
            onAdd: () {},
            onSpend: () {},
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              WalletHistory(
                movements: _movements,
                showEuros: _euros,
                nameOf: (u) => u,
                onTap: (_) {},
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Form extends StatefulWidget {
  const _Form();
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  bool _free = false;
  final _amount = TextEditingController(text: '12000');
  final _km = TextEditingController(text: '214500');
  final _what = TextEditingController(
    text: 'Mali servis\n- ulje 5W30, 4 l\n- filter ulja, vazduha i kabine',
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const SlantAppBar(title: 'Novi servis'),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        InputDecorator(
          decoration: const InputDecoration(
            labelText: 'Auto',
            prefixIcon: Icon(Icons.directions_car_rounded),
            suffixIcon: Icon(Icons.expand_more_rounded),
          ),
          child: const Text('Golf 5 1.9 TDI · BG 123-AB'),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DateField(
                label: 'Datum',
                value: _d(25),
                compact: true,
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _km,
                decoration: const InputDecoration(
                  labelText: 'Kilometraža',
                  helperText: 'Nije obavezno',
                  prefixIcon: Icon(Icons.speed_rounded),
                  suffixText: 'km',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RepairPriceFields(
          free: _free,
          onFree: (v) => setState(() => _free = v),
          amount: _amount,
          currency: Currency.rsd,
          onCurrency: (_) {},
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _what,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Opis',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        SkewSwitchTile(
          title: 'Dodaj iznos u kasu',
          subtitle: 'Iznos servisa ulazi u zajedničku kasu.',
          value: true,
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: SkewButton(
            label: 'Sačuvaj',
            icon: Icons.check_rounded,
            height: 52,
            fontSize: 18,
            onPressed: () {},
          ),
        ),
      ],
    ),
  );
}

Widget _more() => Scaffold(
  bottomNavigationBar: RaceNavBar(items: _nav, index: 3, onChanged: (_) {}),
  body: MoreTab(
    profile: const AppUser(
      uid: 'mika',
      email: 'mika@example.com',
      firstName: 'Mika',
      lastName: 'Mikić',
      role: UserRole.admin,
      disabled: false,
    ),
    onSelect: (_) {},
  ),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    const dir = 'assets/fonts';
    await _font('Exo2', [
      '$dir/Exo2-Regular.ttf',
      '$dir/Exo2-Medium.ttf',
      '$dir/Exo2-SemiBold.ttf',
      '$dir/Exo2-ExtraBold.ttf',
      '$dir/Exo2-BoldItalic.ttf',
      '$dir/Exo2-ExtraBoldItalic.ttf',
    ]);
    await _font('MaterialIcons', ['$_material/MaterialIcons-Regular.otf']);
  });

  Future<void> shot(
    WidgetTester tester,
    String name,
    Widget Function(BuildContext) home, {
    required bool dark,
    AppPalette? palette,
    Future<void> Function()? then,
  }) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 56);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(palette ?? kPalettes.first, dark),
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
    if (then != null) {
      await then();
      await tester.pumpAndSettle();
    }
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('$_out/$name.png'),
    );
  }

  testWidgets(
    'services light',
    (t) => shot(t, 'v2_servisi', _services, dark: false),
  );
  testWidgets(
    'services dark',
    (t) => shot(t, 'v2_servisi_dark', _services, dark: true),
  );
  testWidgets(
    'wallet light',
    (t) => shot(t, 'v2_kasa', (_) => const _Wallet(), dark: false),
  );
  testWidgets(
    'wallet euros dark',
    (t) => shot(
      t,
      'v2_kasa_evri_dark',
      (_) => const _Wallet(),
      dark: true,
      then: () => t.tap(find.byType(SkewSwitch)),
    ),
  );
  testWidgets(
    'form light',
    (t) => shot(t, 'v2_forma', (_) => const _Form(), dark: false),
  );
  testWidgets(
    'more light',
    (t) => shot(t, 'v2_vise', (_) => _more(), dark: false),
  );
  testWidgets(
    'services blue',
    (t) => shot(
      t,
      'v2_servisi_plava',
      _services,
      dark: false,
      palette: kPalettes[1],
    ),
  );
  testWidgets(
    'wallet yellow',
    (t) => shot(
      t,
      'v2_kasa_zuta',
      (_) => const _Wallet(),
      dark: false,
      palette: kPalettes[4],
    ),
  );
}
