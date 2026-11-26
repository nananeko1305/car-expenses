import 'package:car_expenses/classic/theme/app_colors.dart';
import 'package:car_expenses/classic/theme/app_palette.dart';
import 'package:car_expenses/classic/theme/app_theme.dart';
import 'package:car_expenses/classic/widgets/theme_mode_picker.dart';
import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeMode> _loaded(Map<String, Object> stored) async {
  SharedPreferences.setMockInitialValues(stored);
  final controller = ThemeController();
  await controller.load();
  return controller.mode;
}

void main() {
  group('the stored choice', () {
    test('a fresh install follows the phone', () async {
      expect(await _loaded({}), ThemeMode.system);
    });

    test('whoever had the old dark switch on stays dark', () async {
      expect(await _loaded({'dark_mode': true}), ThemeMode.dark);
    });

    test('the old switch being off now follows the phone', () async {
      expect(await _loaded({'dark_mode': false}), ThemeMode.system);
    });

    test('a choice made since wins over the old switch', () async {
      expect(
        await _loaded({'dark_mode': true, 'theme_mode': 'light'}),
        ThemeMode.light,
      );
      expect(
        await _loaded({'dark_mode': true, 'theme_mode': 'system'}),
        ThemeMode.system,
      );
    });

    test('something unreadable counts as never chosen', () async {
      expect(await _loaded({'theme_mode': 'sepia'}), ThemeMode.system);
    });

    test(
      'is kept on the device, announced, and leaves the color alone',
      () async {
        SharedPreferences.setMockInitialValues({'theme_id': kPalettes.last.id});
        final controller = ThemeController();
        await controller.load();
        var announced = 0;
        controller.addListener(() => announced++);

        await controller.setMode(ThemeMode.dark);
        expect(controller.mode, ThemeMode.dark);
        expect(announced, 1);

        final afterRestart = ThemeController();
        await afterRestart.load();
        expect(afterRestart.mode, ThemeMode.dark);
        expect(afterRestart.current.id, kPalettes.last.id);

        await afterRestart.setMode(ThemeMode.system);
        final again = ThemeController();
        await again.load();
        expect(again.mode, ThemeMode.system);
      },
    );
  });

  group('the app', () {
    /// The app's two themes, picked the way main.dart has MaterialApp do it.
    Future<bool> isDark(
      WidgetTester tester,
      ThemeMode mode,
      Brightness phone,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = phone;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      late AppColors colors;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          home: Builder(
            builder: (context) {
              colors = context.colors;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final palette = AppTheme.paletteInUse;
      expect(colors.background, anyOf(palette.bg, palette.darkBg));
      return colors.background == palette.darkBg;
    }

    testWidgets('on auto goes dark and light with the phone', (tester) async {
      expect(await isDark(tester, ThemeMode.system, Brightness.dark), isTrue);
      expect(await isDark(tester, ThemeMode.system, Brightness.light), isFalse);
    });

    testWidgets('on light or dark does not care what the phone is in', (
      tester,
    ) async {
      expect(await isDark(tester, ThemeMode.light, Brightness.dark), isFalse);
      expect(await isDark(tester, ThemeMode.dark, Brightness.light), isTrue);
    });
  });

  group('the picker', () {
    Future<void> pump(
      WidgetTester tester,
      ThemeMode value, {
      ValueChanged<ThemeMode>? onChanged,
      String lang = 'sr',
    }) {
      // A narrow phone, so three Serbian labels must fit side by side.
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.build(kPalettes.first, false),
          locale: Locale(lang),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ThemeModePicker(
                value: value,
                onChanged: onChanged ?? (_) {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('offers auto, light and dark, and says what auto does', (
      tester,
    ) async {
      await pump(tester, ThemeMode.system);
      expect(find.text('Auto'), findsOneWidget);
      expect(find.text('Svetla'), findsOneWidget);
      expect(find.text('Tamna'), findsOneWidget);
      expect(find.text('Auto prati temu telefona.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final picker = tester.widget<SegmentedButton<ThemeMode>>(
        find.byType(SegmentedButton<ThemeMode>),
      );
      expect(picker.selected, {ThemeMode.system});
    });

    testWidgets('hands over the choice that was tapped', (tester) async {
      final chosen = <ThemeMode>[];
      await pump(tester, ThemeMode.system, onChanged: chosen.add, lang: 'en');
      await tester.tap(find.text('Dark'));
      await tester.tap(find.text('Light'));
      expect(chosen, [ThemeMode.dark, ThemeMode.light]);
    });
  });
}
