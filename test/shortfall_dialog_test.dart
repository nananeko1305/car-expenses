import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/shortfall_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('says what is available and what was asked, then closes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.build(kPalettes.first, false),
        locale: const Locale('sr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showShortfallDialog(
                context,
                available: 1000000,
                amount: 1800000,
                currency: Currency.rsd,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Nema dovoljno sredstava u kasi'), findsOneWidget);
    expect(
      find.text(
        'Na raspolaganju je 10.000,00 RSD, a ovaj trošak je '
        '18.000,00 RSD. Kasa ne može da ide u minus.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Zatvori'));
    await tester.pumpAndSettle();
    expect(find.text('Nema dovoljno sredstava u kasi'), findsNothing);
  });
}
