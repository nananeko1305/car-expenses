import 'package:cloud_firestore/cloud_firestore.dart';

import 'repair.dart';

/// Manual wallet movements. Service income is not stored here; it comes
/// straight from repairs with `toWallet == true` (see [WalletMovement]).
enum WalletEntryType { deposit, withdrawal }

/// A manual deposit into, or withdrawal from, the shared wallet,
/// stored in `walletEntries/{id}`.
class WalletEntry {
  const WalletEntry({
    required this.id,
    required this.type,
    required this.amountMinor,
    required this.currency,
    required this.description,
    required this.date,
    required this.userId,
    required this.createdBy,
  });

  final String id;
  final WalletEntryType type;
  final int amountMinor;
  final Currency currency;
  final String description;
  final DateTime date;

  /// Who added or spent the money.
  final String userId;

  /// Who recorded the entry; only they (or the admin) may change it.
  final String createdBy;

  factory WalletEntry.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return WalletEntry(
      id: doc.id,
      type: data['type'] == 'withdrawal'
          ? WalletEntryType.withdrawal
          : WalletEntryType.deposit,
      amountMinor: (data['amountMinor'] as num?)?.toInt() ?? 0,
      currency: currencyFromCode(data['currency'] as String?),
      description: data['description'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'amountMinor': amountMinor,
    'currency': currency.code,
    'description': description,
    'date': Timestamp.fromDate(date),
    'userId': userId,
    'createdBy': createdBy,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// One line in the wallet history: service income, a deposit, or a
/// withdrawal. [signedMinor] is positive for money in, negative for out.
class WalletMovement {
  const WalletMovement._({
    required this.date,
    required this.signedMinor,
    required this.currency,
    required this.description,
    required this.userId,
    this.repair,
    this.entry,
  });

  factory WalletMovement.fromRepair(Repair r) => WalletMovement._(
    date: r.date,
    signedMinor: r.amountMinor,
    currency: r.currency,
    description: r.description,
    userId: r.performedBy,
    repair: r,
  );

  factory WalletMovement.fromEntry(WalletEntry e) => WalletMovement._(
    date: e.date,
    signedMinor: e.type == WalletEntryType.withdrawal
        ? -e.amountMinor
        : e.amountMinor,
    currency: e.currency,
    description: e.description,
    userId: e.userId,
    entry: e,
  );

  final DateTime date;
  final int signedMinor;
  final Currency currency;
  final String description;
  final String userId;
  final Repair? repair;
  final WalletEntry? entry;

  /// Merges service income and manual entries, newest first.
  static List<WalletMovement> merge(
    List<Repair> repairs,
    List<WalletEntry> entries,
  ) {
    final list = [
      for (final r in repairs)
        if (r.toWallet) WalletMovement.fromRepair(r),
      for (final e in entries) WalletMovement.fromEntry(e),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Balance per currency.
  static Map<Currency, int> balances(List<WalletMovement> movements) {
    final sums = <Currency, int>{};
    for (final m in movements) {
      sums[m.currency] = (sums[m.currency] ?? 0) + m.signedMinor;
    }
    return sums;
  }
}
