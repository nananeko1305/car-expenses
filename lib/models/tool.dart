import 'package:cloud_firestore/cloud_firestore.dart';

import 'repair.dart';
import 'warranty.dart';

/// A tool the crew owns, stored in `tools/{id}`. Everything that is not
/// consumable is a tool, and what matters about one is its warranty.
///
/// A tool is never deleted, only archived: it is usually bought by a
/// wallet withdrawal, and deleting the tool would invite deleting the
/// spending with it.
class Tool {
  const Tool({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.purchaseDate,
    required this.warrantyAmount,
    required this.warrantyUnit,
    this.amountMinor,
    this.currency,
    this.entryId = '',
    this.notify = true,
    this.archived = false,
  });

  final String id;

  /// Who recorded it; only they or the admin may change it.
  final String ownerId;

  final String name;

  /// The date on the receipt. The warranty starts the same day.
  final DateTime purchaseDate;

  final int warrantyAmount;
  final WarrantyUnit warrantyUnit;

  /// What it cost, copied from the wallet entry so the price survives if
  /// that entry is ever deleted. Null for a tool entered on its own.
  final int? amountMinor;
  final Currency? currency;

  /// The `walletEntries/{id}` that bought it, or empty.
  final String entryId;

  /// Whether the crew is reminded before the warranty runs out.
  final bool notify;

  final bool archived;

  /// The last day the warranty covers, inclusive.
  DateTime get warrantyEnd =>
      warrantyEndOf(purchaseDate, warrantyAmount, warrantyUnit);

  /// 0 on the day the warranty expires, negative once it has.
  int daysLeft(DateTime now) => daysBetween(now, warrantyEnd);

  double progress(DateTime now) =>
      warrantyProgress(purchaseDate, warrantyEnd, now);

  WarrantyStatus status(DateTime now) => warrantyStatusOf(daysLeft(now));

  factory Tool.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final currency = data['currency'] as String?;
    return Tool(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      purchaseDate:
          (data['purchaseDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      warrantyAmount: (data['warrantyAmount'] as num?)?.toInt() ?? 1,
      warrantyUnit: warrantyUnitFromName(data['warrantyUnit'] as String?),
      amountMinor: (data['amountMinor'] as num?)?.toInt(),
      currency: currency == null ? null : currencyFromCode(currency),
      entryId: data['entryId'] as String? ?? '',
      notify: data['notify'] as bool? ?? true,
      archived: data['archived'] as bool? ?? false,
    );
  }

  /// Deliberately never writes `remindersSent`: that field belongs to the
  /// reminder job, and `update()` only touches the keys it is given.
  Map<String, dynamic> toMap() => {
    'ownerId': ownerId,
    'name': name,
    'purchaseDate': Timestamp.fromDate(purchaseDate),
    'warrantyAmount': warrantyAmount,
    'warrantyUnit': warrantyUnit.name,
    // Mirrors [warrantyEnd] so the reminder job can query it. The app
    // always computes the date instead of reading this back.
    'warrantyEndsAt': Timestamp.fromDate(warrantyEnd),
    'amountMinor': amountMinor,
    'currency': currency?.code,
    'entryId': entryId,
    'notify': notify,
    'archived': archived,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}
