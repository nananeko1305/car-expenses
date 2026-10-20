import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/app_user.dart';
import 'package:car_expenses/models/tutorial.dart';
import 'package:car_expenses/models/tutorial_entry.dart';
import 'package:car_expenses/screens/tutorial_model_form_screen.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/name_dialog.dart';
import 'package:car_expenses/widgets/tutorial_cards.dart';
import 'package:car_expenses/widgets/tutorial_link_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

const _mika = AppUser(
  uid: 'mika',
  email: 'mika@x.rs',
  role: UserRole.user,
  disabled: false,
);

const _vw = TutorialBrand(id: 'vw', ownerId: 'mika', name: 'Volkswagen');

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

/// A button that opens [open], so a dialog can be tested on its own.
Widget _opener(Future<void> Function(BuildContext) open) => Scaffold(
  body: Builder(
    builder: (context) =>
        TextButton(onPressed: () => open(context), child: const Text('open')),
  ),
);

void main() {
  setUpAll(initializeDateFormatting);

  group('name dialog', () {
    late String? result;

    Future<void> open(WidgetTester tester) async {
      result = 'not closed';
      await _pump(
        tester,
        _opener((context) async {
          result = await showNameDialog(
            context,
            title: 'New make',
            label: 'Make',
            hint: 'e.g. Volkswagen',
            taken: const ['Opel', 'Volkswagen'],
            takenMessage: 'This make already exists',
          );
        }),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('refuses an empty name and one already taken', (tester) async {
      await open(tester);
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), '  volkswagen ');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('This make already exists'), findsOneWidget);
      expect(result, 'not closed');
    });

    testWidgets('returns the new name, trimmed', (tester) async {
      await open(tester);
      await tester.enterText(find.byType(TextFormField), ' Škoda ');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(result, 'Škoda');
    });
  });

  testWidgets('the link dialog refuses what is not a web address', (
    tester,
  ) async {
    await _pump(
      tester,
      _opener(
        (context) => showTutorialLinkDialog(context, modelId: 'm1', uid: 'u1'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).last, 'mailto:a@b.rs');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Enter a web address'), findsOneWidget);
    expect(find.text('New link'), findsOneWidget); // still open
  });

  group('new model form', () {
    Widget form() => const TutorialModelFormScreen(
      profile: _mika,
      brand: _vw,
      taken: ['Passat'],
    );

    testWidgets('starts with one link and adds and removes more', (
      tester,
    ) async {
      await _pump(tester, form());
      expect(find.text('Title'), findsOneWidget);
      expect(find.byTooltip('Remove'), findsNothing);

      await tester.tap(find.text('Add another link'));
      await tester.pump();
      expect(find.text('Title'), findsNWidgets(2));
      expect(find.byTooltip('Remove'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();
      expect(find.text('Title'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a link with a title needs its address', (tester) async {
      await _pump(tester, form());
      await tester.enterText(find.byType(TextFormField).at(0), 'Golf 7');
      await tester.enterText(find.byType(TextFormField).at(1), 'Kvačilo');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('refuses a model the make already has', (tester) async {
      await _pump(tester, form());
      await tester.enterText(find.byType(TextFormField).at(0), 'passat');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('This model already exists'), findsOneWidget);
    });

    testWidgets('fits a phone in Serbian', (tester) async {
      await _pump(tester, form(), lang: 'sr');
      await tester.tap(find.text('Dodaj još jedan link'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('cards show a link\'s title and site, and a note\'s author', (
    tester,
  ) async {
    await _pump(
      tester,
      Scaffold(
        body: ListView(
          children: [
            TutorialLinkCard(
              link: const TutorialLink(
                id: 'l1',
                ownerId: 'mika',
                modelId: 'm1',
                title: 'Zamena kvačila',
                url: 'https://www.youtube.com/watch?v=1',
              ),
              onOpen: () {},
              onEdit: () {},
            ),
            TutorialNoteCard(
              note: TutorialNote(
                id: 'n1',
                ownerId: 'mika',
                modelId: 'm1',
                text: 'Zavrtanj alternatora je T50.',
                createdAt: DateTime(2026, 10, 12),
              ),
              authorName: 'Mika',
              onTap: () {},
            ),
          ],
        ),
      ),
      lang: 'sr',
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Zamena kvačila'), findsOneWidget);
    expect(find.text('youtube.com'), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    expect(find.textContaining('Mika · '), findsOneWidget);
  });
}
