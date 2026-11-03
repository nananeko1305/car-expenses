import 'package:car_expenses/l10n/app_localizations.dart';
import 'package:car_expenses/models/app_user.dart';
import 'package:car_expenses/models/tutorial.dart';
import 'package:car_expenses/models/tutorial_entry.dart';
import 'package:car_expenses/screens/note_form_screen.dart';
import 'package:car_expenses/screens/tutorial_model_form_screen.dart';
import 'package:car_expenses/theme/app_palette.dart';
import 'package:car_expenses/theme/app_theme.dart';
import 'package:car_expenses/widgets/name_dialog.dart';
import 'package:car_expenses/widgets/notes_list.dart';
import 'package:car_expenses/widgets/tutorial_cards.dart';
import 'package:car_expenses/widgets/tutorial_link_dialog.dart';
import 'package:car_expenses/widgets/tutorial_note_dialog.dart';
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

final _golfNote = TutorialNote(
  id: 'golf',
  ownerId: 'mika',
  modelId: 'm1',
  text: 'Filter goriva je iza branika.',
  year: '2016',
  engine: '2.0 TDI',
  createdAt: DateTime(2026, 11, 3),
);

/// From before the year and engine.
final _octaviaNote = TutorialNote(
  id: 'octavia',
  ownerId: 'pera',
  modelId: 'm2',
  text: 'Hladan start traje duže.',
  createdAt: DateTime(2026, 10, 12),
);

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

  testWidgets('a note card shows its car, year and engine when it has them', (
    tester,
  ) async {
    await _pump(
      tester,
      Scaffold(
        body: ListView(
          children: [
            TutorialNoteCard(
              note: _golfNote,
              car: 'Volkswagen Golf',
              authorName: 'Mika',
              onTap: () {},
            ),
            TutorialNoteCard(
              note: _octaviaNote,
              authorName: 'Pera',
              onTap: () {},
            ),
          ],
        ),
      ),
      lang: 'sr',
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Volkswagen Golf'), findsOneWidget);
    expect(find.text('2016 · 2.0 TDI'), findsOneWidget);
    expect(find.text('Hladan start traje duže.'), findsOneWidget);
    // Under a model: no car, and nothing for what was not entered.
    expect(find.text('Škoda Octavia'), findsNothing);
  });

  testWidgets('the note dialog asks for a year and an engine, and needs text', (
    tester,
  ) async {
    await _pump(
      tester,
      _opener(
        (context) => showTutorialNoteDialog(context, modelId: 'm1', uid: 'u1'),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Year'), findsOneWidget);
    expect(find.text('Engine'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget); // still open
    expect(tester.takeException(), isNull);
  });

  testWidgets('the note dialog opens with what the note says', (tester) async {
    await _pump(
      tester,
      _opener(
        (context) => showTutorialNoteDialog(
          context,
          modelId: 'golf',
          uid: 'pera',
          note: _golfNote,
          authorName: 'Mika',
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('2016'), findsOneWidget);
    expect(find.text('2.0 TDI'), findsOneWidget);
    expect(find.text('Filter goriva je iza branika.'), findsOneWidget);
  });

  group('new note form', () {
    Widget form() => const NoteFormScreen(
      profile: _mika,
      brands: [
        _vw,
        TutorialBrand(id: 'opel', ownerId: 'mika', name: 'Opel'),
        TutorialBrand(id: 'skoda', ownerId: 'mika', name: 'Škoda'),
      ],
      models: [
        TutorialModel(id: 'golf', ownerId: 'mika', brandId: 'vw', name: 'Golf'),
        TutorialModel(id: 'polo', ownerId: 'mika', brandId: 'vw', name: 'Polo'),
        TutorialModel(
          id: 'astra',
          ownerId: 'mika',
          brandId: 'opel',
          name: 'Astra',
        ),
      ],
    );

    Finder field(int i) => find.byType(TextFormField).at(i);

    testWidgets('needs the make, the model and the text, but not the rest', (
      tester,
    ) async {
      await _pump(tester, form());
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.text('Required'), findsNWidgets(3));
    });

    testWidgets('suggests a make, ignoring our letters', (tester) async {
      await _pump(tester, form());
      await tester.enterText(field(0), 'sko');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Škoda'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(field(0)).controller!.text, 'Škoda');
      expect(tester.takeException(), isNull);
    });

    testWidgets('suggests only the models of the typed make', (tester) async {
      await _pump(tester, form());
      await tester.enterText(field(0), 'volkswagen');
      await tester.pumpAndSettle();
      await tester.tap(field(1));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Golf'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Polo'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Astra'), findsNothing);
    });

    testWidgets('offers the new make\'s models after the make changes', (
      tester,
    ) async {
      await _pump(tester, form());
      // The model field was looked at before any make was typed.
      await tester.tap(field(1));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);

      await tester.enterText(field(0), 'Opel');
      await tester.pumpAndSettle();
      await tester.tap(field(1));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Astra'), findsOneWidget);
    });

    testWidgets('takes a make that does not exist yet', (tester) async {
      await _pump(tester, form());
      await tester.enterText(field(0), 'Lada');
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsNothing);
      expect(tester.widget<TextFormField>(field(0)).controller!.text, 'Lada');
    });

    testWidgets('fits a phone in Serbian', (tester) async {
      await _pump(tester, form(), lang: 'sr');
      await tester.enterText(field(0), 'o');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Godište'), findsOneWidget);
      expect(find.text('Motor'), findsOneWidget);
    });
  });

  group('notes list', () {
    late TutorialNote? opened;

    Widget list(List<TutorialNote> notes) => Scaffold(
      body: NotesList(
        notes: notes,
        carOf: (n) => n.id == 'golf' ? 'Volkswagen Golf' : 'Škoda Octavia',
        authorOf: (n) => 'Mika',
        onOpen: (n) => opened = n,
      ),
    );

    testWidgets('narrows down as you type, and says when nothing is left', (
      tester,
    ) async {
      await _pump(tester, list([_golfNote, _octaviaNote]));
      expect(find.text('Volkswagen Golf'), findsOneWidget);
      expect(find.text('Škoda Octavia'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'tdi golf 2016');
      await tester.pump();
      expect(find.text('Volkswagen Golf'), findsOneWidget);
      expect(find.text('Škoda Octavia'), findsNothing);

      await tester.enterText(find.byType(TextField), 'skoda');
      await tester.pump();
      expect(find.text('Volkswagen Golf'), findsNothing);
      expect(find.text('Škoda Octavia'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'trabant');
      await tester.pump();
      expect(find.text('No notes match this search.'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(find.text('Volkswagen Golf'), findsOneWidget);
      expect(find.text('Škoda Octavia'), findsOneWidget);
    });

    testWidgets('lists the newest first', (tester) async {
      await _pump(tester, list([_octaviaNote, _golfNote]));
      expect(
        tester.getTopLeft(find.text('Volkswagen Golf')).dy,
        lessThan(tester.getTopLeft(find.text('Škoda Octavia')).dy),
      );
    });

    testWidgets('says so when there are no notes at all', (tester) async {
      await _pump(tester, list(const []));
      expect(find.text('No notes yet.'), findsOneWidget);
    });

    testWidgets('opens the note that was tapped', (tester) async {
      opened = null;
      await _pump(tester, list([_golfNote, _octaviaNote]));
      await tester.tap(find.text('Škoda Octavia'));
      expect(opened, _octaviaNote);
    });

    testWidgets('fits a phone in Serbian', (tester) async {
      await _pump(tester, list([_golfNote, _octaviaNote]), lang: 'sr');
      expect(tester.takeException(), isNull);
      expect(find.text('Marka, model, godište, motor…'), findsOneWidget);
    });
  });
}
