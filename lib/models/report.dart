import 'repair.dart';
import 'tool.dart';
import 'wallet_entry.dart';

/// An amount per currency. RSD and EUR are never added together, since
/// there is no reliable exchange rate to apply.
typedef Amounts = Map<Currency, int>;

/// The first day of the month [d] falls in.
DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

/// Whether [d] falls in the same calendar month as [month].
bool inMonth(DateTime d, DateTime month) =>
    d.year == month.year && d.month == month.month;

/// What the workshop did, took in and spent over one calendar month, or
/// over all time. Worked out from the live data, never stored.
class Report {
  const Report._({
    required this.services,
    required this.cars,
    required this.earned,
    required this.otherIncome,
    required this.costs,
    required this.tools,
  });

  /// The month [month] falls in, or all time when it is null.
  ///
  /// Every service counts as earned, whether or not its money went into
  /// the wallet. Costs are all wallet spending plus tools bought outside
  /// the wallet, so [tools] is always a part of [costs].
  factory Report.of({
    DateTime? month,
    required List<Repair> repairs,
    List<WalletEntry> entries = const [],
    List<Tool> tools = const [],
  }) {
    bool within(DateTime d) => month == null || inMonth(d, month);

    final earned = <Currency, int>{};
    final cars = <String>{};
    var services = 0;
    for (final r in repairs) {
      if (!within(r.date)) continue;
      services++;
      cars.add(r.vehicleId);
      _add(earned, r.currency, r.amountMinor);
    }

    final otherIncome = <Currency, int>{};
    final costs = <Currency, int>{};
    final entriesById = <String, WalletEntry>{};
    for (final e in entries) {
      entriesById[e.id] = e;
      if (!within(e.date)) continue;
      final into = e.type == WalletEntryType.deposit ? otherIncome : costs;
      _add(into, e.currency, e.amountMinor);
    }

    final toolSpend = <Currency, int>{};
    for (final t in tools) {
      final entry = entriesById[t.entryId];
      if (entry != null) {
        // Already among the costs; the wallet holds the live price.
        if (within(entry.date)) {
          _add(toolSpend, entry.currency, entry.amountMinor);
        }
      } else if (t.amountMinor != null &&
          t.currency != null &&
          within(t.purchaseDate)) {
        // Paid outside the wallet, so no spending counted it yet.
        _add(toolSpend, t.currency!, t.amountMinor!);
        _add(costs, t.currency!, t.amountMinor!);
      }
    }

    return Report._(
      services: services,
      cars: cars.length,
      earned: earned,
      otherIncome: otherIncome,
      costs: costs,
      tools: toolSpend,
    );
  }

  /// How many services were done.
  final int services;

  /// How many different cars came in.
  final int cars;

  /// What the services brought in.
  final Amounts earned;

  /// Money added to the wallet that did not come from a service.
  final Amounts otherIncome;

  final Amounts costs;

  /// What went on tools; already included in [costs].
  final Amounts tools;

  /// Everything that came in, less everything that went out.
  Amounts get net {
    final sums = <Currency, int>{};
    earned.forEach((c, v) => _add(sums, c, v));
    otherIncome.forEach((c, v) => _add(sums, c, v));
    costs.forEach((c, v) => _add(sums, c, -v));
    return sums;
  }

  /// The first and the last month there is anything to report on, and
  /// never earlier than [now] for the last.
  static ({DateTime first, DateTime last}) span({
    required DateTime now,
    required List<Repair> repairs,
    required List<WalletEntry> entries,
    required List<Tool> tools,
  }) {
    var first = now;
    var last = now;
    for (final d in [
      for (final r in repairs) r.date,
      for (final e in entries) e.date,
      for (final t in tools) t.purchaseDate,
    ]) {
      if (d.isBefore(first)) first = d;
      if (d.isAfter(last)) last = d;
    }
    return (first: monthOf(first), last: monthOf(last));
  }

  static void _add(Map<Currency, int> sums, Currency c, int minor) {
    sums[c] = (sums[c] ?? 0) + minor;
  }
}
