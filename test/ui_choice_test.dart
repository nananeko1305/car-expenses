import 'package:car_expenses/classic/theme/app_palette.dart' as classic;
import 'package:car_expenses/classic/theme/app_theme.dart' as classic;
import 'package:car_expenses/classic/widgets/ui_style_picker.dart' as classic;
import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/services/ui_choice.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/theme/theme_controller.dart';
import 'package:car_expenses/widgets/ui_style_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<UiStyle> _loaded(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final choice = UiChoice();
  await choice.load();
  return choice.style;
}

void main() {
  group('which interface the phone shows', () {
    test('is the new one until someone picks the classic', () async {
      expect(await _loaded({}), UiStyle.leaning);
      expect(await _loaded({'ui_style': 'something else'}), UiStyle.leaning);
    });

    test('is kept on the device and announced', () async {
      SharedPreferences.setMockInitialValues({});
      final choice = UiChoice();
      var announced = 0;
      choice.addListener(() => announced++);

      await choice.set(UiStyle.classic);
      expect(choice.isClassic, isTrue);
      expect(announced, 1);

      final afterRestart = UiChoice();
      await afterRestart.load();
      expect(afterRestart.style, UiStyle.classic);

      await afterRestart.set(UiStyle.leaning);
      expect(await _loaded({'ui_style': 'leaning'}), UiStyle.leaning);
    });
  });

  group('the color, kept once for both interfaces', () {
    tearDown(() async {
      SharedPreferences.setMockInitialValues({});
      await themeController.load();
    });

    test('before anyone chooses, each starts in its own first color', () async {
      SharedPreferences.setMockInitialValues({});
      await themeController.load();
      expect(themeController.colorChosen, isFalse);
      expect(themeController.current.id, kPalettes.first.id);
      expect(classic.AppTheme.paletteInUse.id, classic.kPalettes.first.id);
      expect(kPalettes.first.id, isNot(classic.kPalettes.first.id));
    });

    test('a chosen color shows in both, in each one\'s own shade', () async {
      SharedPreferences.setMockInitialValues({});
      await themeController.load();
      final green = kPalettes.firstWhere((p) => p.id == 'zelena');
      await themeController.select(green);

      expect(themeController.colorChosen, isTrue);
      expect(classic.AppTheme.paletteInUse.id, 'zelena');
      expect(classic.AppTheme.paletteInUse.primary, isNot(green.primary));

      // And it is still chosen after a restart.
      await themeController.load();
      expect(themeController.colorChosen, isTrue);
      expect(classic.AppTheme.paletteInUse.id, 'zelena');
    });

    test('every color exists in both interfaces', () {
      expect(
        kPalettes.map((p) => p.id).toSet(),
        classic.kPalettes.map((p) => p.id).toSet(),
      );
    });
  });

  group('the picker', () {
    Future<void> pump(
      WidgetTester tester,
      ThemeData theme,
      Widget picker, {
      String lang = 'sr',
    }) {
      // A narrow phone, so both labels must fit side by side.
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          theme: theme,
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(padding: const EdgeInsets.all(16), child: picker),
          ),
        ),
      );
    }

    testWidgets('in the new interface offers both and hands over the tap', (
      tester,
    ) async {
      final chosen = <UiStyle>[];
      await pump(
        tester,
        AppTheme.build(kPalettes.first, false),
        UiStylePicker(value: UiStyle.leaning, onChanged: chosen.add),
      );
      expect(find.text('Novi'), findsOneWidget);
      expect(find.text('Stari'), findsOneWidget);
      expect(
        find.text('Posle izbora se vraćaš na početni ekran.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Stari'));
      expect(chosen, [UiStyle.classic]);
    });

    testWidgets('in the classic interface offers the way back', (tester) async {
      final chosen = <UiStyle>[];
      await pump(
        tester,
        classic.AppTheme.build(classic.kPalettes.first, false),
        classic.UiStylePicker(value: UiStyle.classic, onChanged: chosen.add),
        lang: 'en',
      );
      expect(find.text('Classic'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('New'));
      expect(chosen, [UiStyle.leaning]);
    });
  });
}
