import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<SystemUiOverlayStyle?> _styleFor(WidgetTester tester, bool dark) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.build(kPalettes.first, dark),
      home: Scaffold(appBar: AppBar(title: const Text('Services'))),
    ),
  );
  await tester.pump();
  return SystemChrome.latestStyle;
}

void main() {
  // Regression: the transparent AppBar left white status-bar icons on
  // the light theme, making the clock and icons invisible.
  testWidgets('light theme uses dark status-bar icons', (tester) async {
    final style = await _styleFor(tester, false);
    expect(style?.statusBarIconBrightness, Brightness.dark);
  });

  testWidgets('dark theme uses light status-bar icons', (tester) async {
    final style = await _styleFor(tester, true);
    expect(style?.statusBarIconBrightness, Brightness.light);
  });
}
