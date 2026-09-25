import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/receipt_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _url =
    'https://res.cloudinary.com/nnarit58/image/upload/v1/ztfubikg4gep48y5oaue.jpg';

Future<ListTile> _pump(
  WidgetTester tester, {
  required String url,
  required bool enabled,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, false),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: ReceiptField(
          url: url,
          enabled: enabled,
          configured: true,
          onChanged: (_) {},
        ),
      ),
    ),
  );
  return tester.widget<ListTile>(find.byType(ListTile));
}

void main() {
  // Regression: opening the picture was gated on being allowed to edit
  // the tool, so everyone could see only the receipts they added.
  testWidgets('anyone can open a receipt they may not edit', (tester) async {
    final tile = await _pump(tester, url: _url, enabled: false);
    expect(tile.onTap, isNotNull);
    expect(tile.trailing, isNull, reason: 'no edit or remove buttons');
  });

  testWidgets('the author gets the edit and remove buttons', (tester) async {
    final tile = await _pump(tester, url: _url, enabled: true);
    expect(tile.onTap, isNotNull);
    expect(tile.trailing, isNotNull);
  });

  testWidgets('without a receipt, only the author can add one', (tester) async {
    expect((await _pump(tester, url: '', enabled: false)).onTap, isNull);
    expect((await _pump(tester, url: '', enabled: true)).onTap, isNotNull);
  });
}
