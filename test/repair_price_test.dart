import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/repair_card.dart';
import 'package:car_expenses/widgets/repair_price_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// The price part of the service form, with the state the form keeps.
class _Form extends StatefulWidget {
  const _Form({required this.formKey, this.free = false, this.enabled = true});

  final GlobalKey<FormState> formKey;
  final bool free;
  final bool enabled;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late bool _free = widget.free;
  Currency _currency = Currency.rsd;
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: widget.formKey,
    child: RepairPriceFields(
      free: _free,
      onFree: (v) => setState(() => _free = v),
      amount: _amount,
      currency: _currency,
      onCurrency: (c) => setState(() => _currency = c),
      enabled: widget.enabled,
    ),
  );
}

/// A narrow phone, so long Serbian labels must fit.
Future<void> _pump(WidgetTester tester, Widget body, {String lang = 'en'}) {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: Locale(lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: body)),
    ),
  );
}

Repair _repair(int minor) => Repair(
  id: 'r$minor',
  ownerId: 'u1',
  vehicleId: 'v1',
  date: DateTime(2026, 11, 20),
  amountMinor: minor,
  currency: Currency.rsd,
  description: 'Mali servis',
);

void main() {
  setUpAll(initializeDateFormatting);

  group('the price of a service', () {
    testWidgets('asks for an amount unless marked as no charge', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await _pump(tester, _Form(formKey: form));
      expect(find.text('Amount'), findsOneWidget);
      expect(find.text('EUR €'), findsOneWidget);
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isFalse,
      );

      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Enter an amount greater than 0'), findsOneWidget);
    });

    testWidgets('no charge takes the amount and the currency away', (
      tester,
    ) async {
      final form = GlobalKey<FormState>();
      await _pump(tester, _Form(formKey: form));
      await tester.tap(find.text('No charge'));
      await tester.pump();

      expect(find.text('Amount'), findsNothing);
      expect(find.text('EUR €'), findsNothing);
      expect(form.currentState!.validate(), isTrue);

      // And back: a price can be asked for after all.
      await tester.tap(find.text('No charge'));
      await tester.pump();
      expect(find.text('Amount'), findsOneWidget);
      expect(form.currentState!.validate(), isFalse);
    });

    testWidgets('a service saved with no charge opens that way', (
      tester,
    ) async {
      await _pump(tester, _Form(formKey: GlobalKey<FormState>(), free: true));
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      expect(find.text('Amount'), findsNothing);
    });

    testWidgets('cannot be switched by someone who may only look', (
      tester,
    ) async {
      await _pump(
        tester,
        _Form(formKey: GlobalKey<FormState>(), enabled: false),
      );
      await tester.tap(find.text('No charge'));
      await tester.pump();
      expect(find.text('Amount'), findsOneWidget);
    });

    testWidgets('fits its Serbian wording on a narrow phone', (tester) async {
      await _pump(tester, _Form(formKey: GlobalKey<FormState>()), lang: 'sr');
      expect(find.text('Bez naplate'), findsOneWidget);
      expect(find.text('Radim sebi ili besplatno.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('the service card', () {
    Widget card(Repair repair) => RepairCard(
      repair: repair,
      vehicle: null,
      authorName: 'Pera',
      onTap: () {},
    );

    testWidgets('says no charge instead of a zero amount', (tester) async {
      await _pump(tester, card(_repair(0)), lang: 'sr');
      expect(find.text('Bez naplate'), findsOneWidget);
      expect(find.textContaining('RSD'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('still shows the amount of a paid service', (tester) async {
      await _pump(tester, card(_repair(1500000)), lang: 'sr');
      expect(find.text('15.000,00 RSD'), findsOneWidget);
      expect(find.text('Bez naplate'), findsNothing);
    });
  });
}
