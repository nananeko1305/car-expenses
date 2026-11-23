import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/planned_purchase.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/planned_purchase_card.dart';
import 'package:car_expenses/widgets/planned_purchase_dialog.dart';
import 'package:car_expenses/widgets/purchase_priority.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

final _jack = PlannedPurchase(
  id: 'jack',
  ownerId: 'mika',
  name: 'Dizalica od 3 tone',
  priority: PurchasePriority.high,
  note: 'Stara pušta ulje.',
  createdAt: DateTime(2026, 11, 3),
);

final _gloves = PlannedPurchase(
  id: 'gloves',
  ownerId: 'pera',
  name: 'Rukavice',
  priority: PurchasePriority.medium,
  createdAt: DateTime(2026, 11, 2),
);

final _paper = PlannedPurchase(
  id: 'paper',
  ownerId: 'mika',
  name: 'Papir za štampač',
  priority: PurchasePriority.low,
  createdAt: DateTime(2026, 11, 1),
);

String _nameOf(String uid) => uid == 'mika' ? 'Mika' : 'Pera';

/// A narrow phone, so long Serbian labels must fit.
Future<void> _pump(WidgetTester tester, Widget home, {String lang = 'en'}) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

Widget _list(
  List<PlannedPurchase> purchases, {
  ValueChanged<PlannedPurchase>? onTap,
}) => Scaffold(
  body: PlannedPurchaseList(
    purchases: purchases,
    nameOf: _nameOf,
    onTap: onTap ?? (_) {},
  ),
);

/// A button that opens the dialog, so it can be tested on its own.
Widget _opener({PlannedPurchase? purchase}) => Scaffold(
  body: Builder(
    builder: (context) => TextButton(
      onPressed: () => showPlannedPurchaseDialog(
        context,
        uid: 'pera',
        purchase: purchase,
        authorName: 'Mika',
      ),
      child: const Text('open'),
    ),
  ),
);

double _top(WidgetTester tester, String text) =>
    tester.getTopLeft(find.text(text)).dy;

void main() {
  setUpAll(initializeDateFormatting);

  group('the list', () {
    testWidgets('puts the urgent on top, whatever order they arrive in', (
      tester,
    ) async {
      await _pump(tester, _list([_paper, _jack, _gloves]), lang: 'sr');
      expect(tester.takeException(), isNull);

      final order = [
        'Dizalica od 3 tone',
        'Rukavice',
        'Papir za štampač',
      ].map((text) => _top(tester, text)).toList();
      expect(order, [...order]..sort());
    });

    testWidgets('every item says its own priority, in its own card', (
      tester,
    ) async {
      await _pump(tester, _list([_paper, _jack, _gloves]), lang: 'sr');
      for (final (name, priority) in [
        ('Dizalica od 3 tone', 'Hitno'),
        ('Rukavice', 'Srednje'),
        ('Papir za štampač', 'Nije hitno'),
      ]) {
        final card = find.ancestor(
          of: find.text(name),
          matching: find.byType(PlannedPurchaseCard),
        );
        expect(
          find.descendant(of: card, matching: find.text(priority)),
          findsOneWidget,
          reason: name,
        );
      }
    });

    testWidgets('urgent is red, medium yellow and not urgent green', (
      tester,
    ) async {
      await _pump(tester, _list([_paper, _jack, _gloves]));
      double hue(String label) {
        final pill = tester.widget<Container>(
          find.descendant(
            of: find.ancestor(
              of: find.text(label),
              matching: find.byType(PriorityPill),
            ),
            matching: find.byType(Container),
          ),
        );
        final color = (pill.decoration! as BoxDecoration).color!;
        return HSLColor.fromColor(color).hue;
      }

      expect(hue('Urgent'), anyOf(lessThan(15), greaterThan(345)));
      expect(hue('Medium'), inInclusiveRange(40, 65));
      expect(hue('Not urgent'), inInclusiveRange(100, 160));
    });

    testWidgets('shows the note, and who added it', (tester) async {
      await _pump(tester, _list([_jack, _gloves]), lang: 'sr');
      expect(find.text('Stara pušta ulje.'), findsOneWidget);
      expect(find.textContaining('Mika · '), findsOneWidget);
      expect(find.textContaining('Pera · '), findsOneWidget);
    });

    testWidgets('has no headings, only what the items say', (tester) async {
      await _pump(tester, _list([_jack, _jack, _gloves]));
      expect(find.text('Urgent'), findsNWidgets(2));
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Not urgent'), findsNothing);
    });

    testWidgets('says so when there is nothing to buy', (tester) async {
      await _pump(tester, _list(const []), lang: 'sr');
      expect(find.textContaining('Još nema ničeg za kupovinu.'), findsOne);
      expect(tester.takeException(), isNull);
    });

    testWidgets('hands over the item that was tapped', (tester) async {
      PlannedPurchase? tapped;
      await _pump(tester, _list([_jack, _gloves], onTap: (p) => tapped = p));
      await tester.tap(find.text('Rukavice'));
      expect(tapped?.id, 'gloves');
    });

    testWidgets('fits a long name and note on a phone', (tester) async {
      final long = PlannedPurchase(
        id: 'long',
        ownerId: 'mika',
        name: 'Pneumatski udarni odvijač sa nastavcima ' * 2,
        priority: PurchasePriority.high,
        note: 'Pitati u dve radnje pre kupovine. ' * 12,
        createdAt: DateTime(2026, 11, 3),
      );
      await _pump(tester, _list([long]), lang: 'sr');
      expect(tester.takeException(), isNull);
    });
  });

  group('the dialog', () {
    testWidgets('starts a new item at medium, and needs a name', (
      tester,
    ) async {
      await _pump(tester, _opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('What to buy'), findsOneWidget);
      expect(_selected(tester, 'Medium'), isTrue);
      expect(find.byTooltip('Delete'), findsNothing);

      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('New item'), findsOneWidget); // still open
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticks the priority that was tapped, and only that one', (
      tester,
    ) async {
      await _pump(tester, _opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Urgent'));
      await tester.pump();
      expect(_selected(tester, 'Urgent'), isTrue);
      expect(_selected(tester, 'Medium'), isFalse);
      expect(_selected(tester, 'Not urgent'), isFalse);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('opens with what the item says', (tester) async {
      await _pump(tester, _opener(purchase: _jack), lang: 'sr');
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Izmena stavke'), findsOneWidget);
      expect(find.text('Dizalica od 3 tone'), findsOneWidget);
      expect(find.text('Stara pušta ulje.'), findsOneWidget);
      expect(_selected(tester, 'Hitno'), isTrue);
      expect(find.text('Uneo/la: Mika'), findsOneWidget);
      expect(find.byTooltip('Obriši'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Whether the priority row called [label] is the ticked one.
bool _selected(WidgetTester tester, String label) => tester
    .widget<ListTile>(
      find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
    )
    .selected;
