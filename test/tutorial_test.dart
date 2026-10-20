import 'package:car_expenses/models/tutorial.dart';
import 'package:car_expenses/models/tutorial_entry.dart';
import 'package:flutter_test/flutter_test.dart';

TutorialLink _link(String title, String url, [DateTime? createdAt]) =>
    TutorialLink(
      id: title,
      ownerId: 'u1',
      modelId: 'm1',
      title: title,
      url: url,
      createdAt: createdAt,
    );

TutorialNote _note(String id, [DateTime? createdAt]) => TutorialNote(
  id: id,
  ownerId: 'u1',
  modelId: 'm1',
  text: id,
  createdAt: createdAt,
);

void main() {
  group('normalizeUrl', () {
    test('adds https to an address typed without one', () {
      expect(
        normalizeUrl('  youtube.com/watch?v=aB3  '),
        'https://youtube.com/watch?v=aB3',
      );
      expect(normalizeUrl('vw-club.rs:8080/x'), 'https://vw-club.rs:8080/x');
    });

    test('keeps http and https, in lower case', () {
      expect(normalizeUrl('http://a.rs/X'), 'http://a.rs/X');
      expect(normalizeUrl('HTTPS://YouTube.com/A'), 'https://youtube.com/A');
    });

    test('refuses what is not a web address', () {
      for (final bad in [
        '',
        '   ',
        'mailto:mika@a.rs',
        'javascript:alert(1)',
        'ftp://a.rs/file',
        'zamena kvacila',
        'localhost',
        'https://',
      ]) {
        expect(normalizeUrl(bad), isNull, reason: bad);
      }
    });
  });

  test('a link without a title shows its address', () {
    expect(_link('Kvačilo', 'https://youtube.com/x').label, 'Kvačilo');
    expect(
      _link('', 'https://www.vw-club.rs/fuse').label,
      'www.vw-club.rs/fuse',
    );
    expect(_link('', 'https://www.vw-club.rs/fuse').host, 'vw-club.rs');
  });

  test('YouTube links are videos', () {
    expect(_link('', 'https://www.youtube.com/watch?v=1').isVideo, isTrue);
    expect(_link('', 'https://m.youtube.com/watch?v=1').isVideo, isTrue);
    expect(_link('', 'https://youtu.be/1').isVideo, isTrue);
    expect(_link('', 'https://notyoutube.com/1').isVideo, isFalse);
  });

  test('links keep the order they were added, one saving last', () {
    final links = TutorialLink.inOrder([
      _link('saving', 'https://a.rs'),
      _link('second', 'https://a.rs', DateTime(2026, 10, 2)),
      _link('first', 'https://a.rs', DateTime(2026, 10, 1)),
    ]);
    expect(links.map((l) => l.id), ['first', 'second', 'saving']);
  });

  test('notes are newest first, one saving at the top', () {
    final notes = TutorialNote.newestFirst([
      _note('old', DateTime(2026, 9, 1)),
      _note('saving'),
      _note('new', DateTime(2026, 10, 1)),
    ]);
    expect(notes.map((n) => n.id), ['saving', 'new', 'old']);
  });

  test('names sort and clash ignoring case', () {
    expect(sortedByName(['Volkswagen', 'audi', 'BMW'], (s) => s), [
      'audi',
      'BMW',
      'Volkswagen',
    ]);
    expect(nameTaken(' volkswagen ', ['Opel', 'Volkswagen']), isTrue);
    expect(nameTaken('Passat B8', ['Passat']), isFalse);
  });
}
