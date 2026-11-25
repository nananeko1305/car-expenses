import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/slant_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _red = kPalettes.firstWhere((p) => p.id == 'crvena');
final _yellow = kPalettes.firstWhere((p) => p.id == 'zuta');

Future<Brightness?> _iconsOver(
  WidgetTester tester,
  PreferredSizeWidget bar,
  AppPalette palette, {
  required bool dark,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(palette, dark),
      home: Scaffold(appBar: bar),
    ),
  );
  await tester.pump();
  return SystemChrome.latestStyle?.statusBarIconBrightness;
}

void main() {
  // The header is an accent block that reaches under the status bar, so
  // the clock and icons have to be readable on the accent, whatever the
  // theme is. Once, on a transparent bar, they were white on white.
  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';

    testWidgets('status-bar icons are light on a red header ($theme)', (
      tester,
    ) async {
      for (final bar in <PreferredSizeWidget>[
        const SlantAppBar(title: 'Services'),
        AppBar(title: const Text('Services')),
      ]) {
        expect(
          await _iconsOver(tester, bar, _red, dark: dark),
          Brightness.light,
        );
      }
    });

    testWidgets('and dark on a yellow one, which is written on in ink '
        '($theme)', (tester) async {
      for (final bar in <PreferredSizeWidget>[
        const SlantAppBar(title: 'Services'),
        AppBar(title: const Text('Services')),
      ]) {
        expect(
          await _iconsOver(tester, bar, _yellow, dark: dark),
          Brightness.dark,
        );
      }
    });
  }
}
