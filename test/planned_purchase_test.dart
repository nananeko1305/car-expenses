import 'package:car_expenses/models/planned_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

PlannedPurchase _p(
  String id,
  PurchasePriority priority, [
  DateTime? createdAt,
]) => PlannedPurchase(
  id: id,
  ownerId: 'u1',
  name: id,
  priority: priority,
  createdAt: createdAt,
);

void main() {
  group('the order of the list', () {
    Iterable<String> ids(List<PlannedPurchase> all) =>
        PlannedPurchase.inOrder(all).map((p) => p.id);

    test('the most urgent comes first, however old the rest is', () {
      expect(
        ids([
          _p('paper', PurchasePriority.low, DateTime(2026, 11, 1)),
          _p('jack', PurchasePriority.high, DateTime(2026, 11, 3)),
          _p('gloves', PurchasePriority.medium, DateTime(2026, 11, 2)),
        ]),
        ['jack', 'gloves', 'paper'],
      );
    });

    test('within a priority, the longest waiting is first', () {
      expect(
        ids([
          _p('saving', PurchasePriority.high),
          _p('second', PurchasePriority.high, DateTime(2026, 11, 2)),
          _p('low', PurchasePriority.low, DateTime(2026, 1, 1)),
          _p('first', PurchasePriority.high, DateTime(2026, 10, 30)),
        ]),
        ['first', 'second', 'saving', 'low'],
      );
    });

    test('two written at the same moment keep their places', () {
      final at = DateTime(2026, 11, 3);
      final a = _p('a', PurchasePriority.medium, at);
      final b = _p('b', PurchasePriority.medium, at);
      expect(ids([a, b]), ['a', 'b']);
      expect(ids([b, a]), ['a', 'b']);
    });

    test('an empty list stays empty, and the input is left alone', () {
      expect(PlannedPurchase.inOrder(const []), isEmpty);
      final input = [
        _p('low', PurchasePriority.low, DateTime(2026)),
        _p('high', PurchasePriority.high, DateTime(2026)),
      ];
      PlannedPurchase.inOrder(input);
      expect(input.map((p) => p.id), ['low', 'high']);
    });
  });

  group('reading and writing', () {
    test('a stored item comes back whole', () {
      final read = PlannedPurchase.fromMap('p1', {
        'ownerId': 'mika',
        'name': 'Dizalica',
        'priority': 'high',
        'note': 'Od 3 tone',
        'createdAt': Timestamp.fromDate(DateTime(2026, 11, 3)),
      });
      expect(read.id, 'p1');
      expect(read.ownerId, 'mika');
      expect(read.name, 'Dizalica');
      expect(read.priority, PurchasePriority.high);
      expect(read.note, 'Od 3 tone');
      expect(read.createdAt, DateTime(2026, 11, 3));
    });

    test('a priority this version does not know counts as medium', () {
      expect(PurchasePriority.parse('someday'), PurchasePriority.medium);
      expect(PurchasePriority.parse(null), PurchasePriority.medium);
      expect(PlannedPurchase.fromMap('p1', const {}).note, '');
    });

    test('every priority is stored under a name the rules accept', () {
      expect(PurchasePriority.values.map((p) => p.name), [
        'low',
        'medium',
        'high',
      ]);
      for (final priority in PurchasePriority.values) {
        expect(PurchasePriority.parse(priority.name), priority);
      }
    });

    test('saving an edit leaves the time it was added alone', () {
      final map = _p('jack', PurchasePriority.high, DateTime(2026)).toMap();
      expect(map.containsKey('createdAt'), isFalse);
      expect(map['priority'], 'high');
      expect(map['note'], '');
    });
  });
}
