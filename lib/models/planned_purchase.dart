import 'package:cloud_firestore/cloud_firestore.dart';

/// How soon something on the to-buy list is needed. Stored by name, and
/// declared from the least urgent to the most: the list sorts on that.
enum PurchasePriority {
  low,
  medium,
  high;

  /// The most urgent first, which is the order the picker offers them in.
  static const mostUrgentFirst = [high, medium, low];

  /// Anything unknown counts as [medium], so a value a newer version
  /// writes still shows up on an older one.
  static PurchasePriority parse(Object? name) =>
      values.where((p) => p.name == name).firstOrNull ?? medium;
}

/// Something the workshop still has to buy, stored in
/// `plannedPurchases/{id}`. Shared like the tutorials: anyone may add,
/// correct or delete one, and [ownerId] keeps who added it.
class PlannedPurchase {
  const PlannedPurchase({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.priority,
    this.note = '',
    this.createdAt,
  });

  final String id;
  final String ownerId;

  /// What to buy, e.g. "3-ton jack".
  final String name;
  final PurchasePriority priority;

  /// Anything worth adding, such as where to get it; may be empty.
  final String note;

  /// Null while the write is still on its way to the server.
  final DateTime? createdAt;

  /// [all] as the list shows them: the most urgent first. Within a
  /// priority the one waiting longest comes first, and one still saving
  /// last.
  static List<PlannedPurchase> inOrder(Iterable<PlannedPurchase> all) =>
      all.toList()..sort((a, b) {
        final byPriority = b.priority.index.compareTo(a.priority.index);
        if (byPriority != 0) return byPriority;
        final byAge = _when(a.createdAt).compareTo(_when(b.createdAt));
        // The sort is not stable, so two written at once need a tie-break
        // to keep their places from one rebuild to the next.
        return byAge != 0 ? byAge : a.id.compareTo(b.id);
      });

  factory PlannedPurchase.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      PlannedPurchase.fromMap(doc.id, doc.data() ?? const {});

  factory PlannedPurchase.fromMap(String id, Map<String, dynamic> data) {
    return PlannedPurchase(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      priority: PurchasePriority.parse(data['priority']),
      note: data['note'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Leaves out `createdAt`: the repository sets it once, on create.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'priority': priority.name,
    'note': note,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// A write still on its way has no time yet; it counts as the newest.
DateTime _when(DateTime? d) => d ?? DateTime(9999);
