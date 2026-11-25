// More screens drawn to PNG files from the real widgets and made-up data;
// see main_screens.dart for what this is and why it is not a test.
//
//   flutter test test/shots/more_screens.dart --update-goldens \
//     --dart-define=OUT=/absolute/folder/for/the/pictures

import 'dart:io';

import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/planned_purchase.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/report.dart';
import 'package:car_expenses/models/tool.dart';
import 'package:car_expenses/models/tutorial_entry.dart';
import 'package:car_expenses/models/vehicle.dart';
import 'package:car_expenses/models/warranty.dart';
import 'package:car_expenses/screens/login_screen.dart';
import 'package:car_expenses/theme/app_colors.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/month_grid.dart';
import 'package:car_expenses/widgets/month_switcher.dart';
import 'package:car_expenses/widgets/option_sheet.dart';
import 'package:car_expenses/widgets/planned_purchase_card.dart';
import 'package:car_expenses/widgets/repair_card.dart';
import 'package:car_expenses/widgets/report_view.dart';
import 'package:car_expenses/widgets/skewed.dart';
import 'package:car_expenses/widgets/slant_header.dart';
import 'package:car_expenses/widgets/theme_mode_picker.dart';
import 'package:car_expenses/widgets/tool_card.dart';
import 'package:car_expenses/widgets/tutorial_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Tool _tool(String name, int monthsAgo, int years, {int? minor, bool receipt = false, bool archived = false}) => Tool(
  id: name, ownerId: 'mika', name: name,
  purchaseDate: DateTime(_now.year, _now.month - monthsAgo, 12),
  warrantyAmount: years, warrantyUnit: WarrantyUnit.years,
  amountMinor: minor, currency: minor == null ? null : Currency.rsd,
  receiptUrl: receipt ? 'https://example.com/r.jpg' : '', archived: archived,
);

Widget _tools(BuildContext context) => Scaffold(
  appBar: const SlantAppBar(title: 'Alat'),
  floatingActionButton: SkewFab(label: 'Dodaj alat', icon: Icons.add_rounded, onPressed: () {}),
  body: Column(children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: SegmentedButton<bool>(
        segments: const [ButtonSegment(value: false, label: Text('U upotrebi')), ButtonSegment(value: true, label: Text('Arhivirano'))],
        selected: const {false}, showSelectedIcon: false, onSelectionChanged: (_) {},
      ),
    ),
    Divider(height: 1, color: context.colors.line),
    Expanded(child: ListView(children: [
      ToolCard(tool: _tool('Pneumatski udarni odvijač 1/2', 3, 2, minor: 1850000, receipt: true), now: _now, amountMinor: 1850000, currency: Currency.rsd, onTap: () {}),
      ToolCard(tool: _tool('Dizalica krokodil 3 t', 23, 2, minor: 2400000), now: _now, amountMinor: 2400000, currency: Currency.rsd, onTap: () {}),
      ToolCard(tool: _tool('Dijagnostika OBD', 30, 2, minor: 5200000, receipt: true), now: _now, amountMinor: 5200000, currency: Currency.rsd, onTap: () {}),
      ToolCard(tool: _tool('Set gedora 1/2, 94 dela', 8, 5), now: _now, onTap: () {}),
    ])),
  ]),
);

Widget _tutorials(BuildContext context) => Scaffold(
  appBar: SlantAppBar(title: 'Volkswagen Passat B6', actions: [
    IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () {}),
    IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () {}),
  ]),
  body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
    const SectionTitle('Linkovi'),
    TutorialLinkCard(link: const TutorialLink(id: '1', ownerId: 'm', modelId: 'p', title: 'Zamena zupčastog kaiša 2.0 TDI', url: 'https://www.youtube.com/watch?v=x'), onOpen: () {}, onEdit: () {}),
    TutorialLinkCard(link: const TutorialLink(id: '2', ownerId: 'm', modelId: 'p', title: 'Momenti pritezanja, prednji trap', url: 'https://example.com/passat/momenti'), onOpen: () {}, onEdit: () {}),
    Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(left: 4, top: 2), child: TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add_rounded), label: const Text('Dodaj link')))),
    const SectionTitle('Beleške'),
    TutorialNoteCard(note: TutorialNote(id: 'n1', ownerId: 'm', modelId: 'p', text: 'Zadnji klizači se zapeku: skinuti, očistiti i podmazati pri svakoj zameni pločica.', year: '2008', engine: '2.0 TDI', createdAt: _d(3)), authorName: 'Mika', onTap: () {}),
    TutorialNoteCard(note: TutorialNote(id: 'n2', ownerId: 'p', modelId: 'p', text: 'EGR ventil je iza motora, lakše se prilazi odozdo.', createdAt: _d(9)), authorName: 'Pera', onTap: () {}),
    const SectionTitle('Marke'),
    TutorialTile(icon: Icons.directions_car_rounded, title: 'Volkswagen', subtitle: '3 modela', onTap: () {}),
    TutorialTile(icon: Icons.directions_car_rounded, title: 'Opel', subtitle: '2 modela', onTap: () {}),
  ]),
);

PlannedPurchase _buy(String name, PurchasePriority p, int day, [String note = '']) =>
    PlannedPurchase(id: name, ownerId: 'mika', name: name, priority: p, note: note, createdAt: _d(day));

Widget _toBuy(BuildContext context) => Scaffold(
  appBar: const SlantAppBar(title: 'Za kupovinu'),
  floatingActionButton: SkewFab(label: 'Dodaj stavku', icon: Icons.add_rounded, onPressed: () {}),
  body: PlannedPurchaseList(
    purchases: [
      _buy('Dizalica od 3 tone', PurchasePriority.high, 3, 'Stara pušta ulje.'),
      _buy('Kočiona tečnost DOT 4, 5 l', PurchasePriority.high, 6),
      _buy('Rukavice, nitril L', PurchasePriority.medium, 2),
      _buy('Papir za štampač', PurchasePriority.low, 1),
    ],
    nameOf: (_) => 'Mika', onTap: (_) {},
  ),
);

Repair _r(int day, String what, int minor) => Repair(id: '$day', ownerId: 'Mika', vehicleId: 'g', date: _d(day),
    amountMinor: minor, currency: Currency.rsd, description: what, mileage: 214500);
const _golf = Vehicle(id: 'g', ownerId: 'mika', name: 'Golf 5 1.9 TDI', plate: 'BG 123-AB');

Widget _report(BuildContext context) {
  final repairs = [_r(24, 'Mali servis', 1200000), _r(21, 'Zamena kvačila i zamajca', 5400000), _r(20, 'Mali servis, moj auto', 0)];
  return Scaffold(
    appBar: const SlantAppBar(title: 'Mesečni izveštaj'),
    body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: SegmentedButton<bool>(
          segments: const [ButtonSegment(value: false, label: Text('Po mesecima')), ButtonSegment(value: true, label: Text('Ukupno'))],
          selected: const {false}, showSelectedIcon: false, onSelectionChanged: (_) {},
        ),
      ),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: MonthSwitcher(month: monthOf(_now), first: DateTime(_now.year, 1), last: monthOf(_now), onChanged: (_) {})),
      Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 0), child: ReportView(report: Report.of(month: _now, repairs: repairs))),
      const SectionTitle('Servisi'),
      Divider(height: 1, color: context.colors.line),
      for (final r in repairs) RepairCard(repair: r, vehicle: _golf, authorName: 'Mika', onTap: () {}),
    ]),
  );
}

Widget _calendar(BuildContext context) => Scaffold(
  appBar: const SlantAppBar(title: 'Kalendar'),
  floatingActionButton: SkewFab(label: 'Zakaži', icon: Icons.add_rounded, onPressed: () {}),
  body: ListView(children: [
    Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: MonthSwitcher(month: monthOf(_now), first: DateTime(_now.year, 1), last: DateTime(_now.year + 1, 1), onChanged: (_) {})),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MonthGrid(month: _now, selected: _d(18), today: _d(25), counts: {_d(18): 2, _d(20): 1, _d(27): 3}, onSelect: (_) {}),
    ),
    const SectionTitle('Tema'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ThemeModePicker(value: ThemeMode.system, onChanged: (_) {})),
  ]),
);

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
    SharedPreferences.setMockInitialValues({});
    const dir = 'assets/fonts';
    await _font('Exo2', ['$dir/Exo2-Regular.ttf', '$dir/Exo2-Medium.ttf', '$dir/Exo2-SemiBold.ttf', '$dir/Exo2-ExtraBold.ttf', '$dir/Exo2-BoldItalic.ttf', '$dir/Exo2-ExtraBoldItalic.ttf']);
    await _font('MaterialIcons', ['$_material/MaterialIcons-Regular.otf']);
  });

  Future<void> shot(WidgetTester tester, String name, Widget Function(BuildContext) home, {bool dark = false, Future<void> Function()? then}) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    tester.view.padding = const FakeViewPadding(top: 56);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(kPalettes.first, dark),
      locale: const Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('en'), Locale('sr'), Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn')],
      home: Builder(builder: home),
    ));
    await tester.pumpAndSettle();
    if (then != null) {
      await then();
      await tester.pumpAndSettle();
    }
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('$_out/$name.png'));
  }

  testWidgets('tools', (t) => shot(t, 'v2_alat', _tools));
  testWidgets('tutorials', (t) => shot(t, 'v2_tutorijali', _tutorials));
  testWidgets('to buy', (t) => shot(t, 'v2_kupovina', _toBuy));
  testWidgets('report', (t) => shot(t, 'v2_izvestaj', _report));
  testWidgets('calendar', (t) => shot(t, 'v2_kalendar', _calendar));
  testWidgets('login', (t) => shot(t, 'v2_prijava', (_) => const LoginScreen()));
  testWidgets('option sheet dark', (t) => shot(t, 'v2_izbor_dark', (context) => Scaffold(
    body: Center(child: TextButton(
      onPressed: () => showOptionSheet(context, icon: Icons.directions_car_rounded, title: 'Auto', allLabel: 'Svi automobili', value: 'a', options: const [
        SheetOption(id: 'g', label: 'Golf 5 1.9 TDI · BG 123-AB', subtitle: '12 servisa'),
        SheetOption(id: 'a', label: 'Astra H · NS 456-CD', subtitle: '4 servisa'),
      ]),
      child: const Text('otvori'),
    )),
  ), dark: true, then: () => t.tap(find.text('otvori'))));
}
