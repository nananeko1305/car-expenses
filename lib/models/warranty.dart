/// Warranty maths for tools, kept free of Firestore so the UI, the model
/// and the tests can all share it.
library;

enum WarrantyUnit { months, years }

WarrantyUnit warrantyUnitFromName(String? name) =>
    name == 'years' ? WarrantyUnit.years : WarrantyUnit.months;

/// How a warranty reads at a glance. A full progress bar alone cannot
/// tell "expires today" from "expired three years ago".
enum WarrantyStatus { active, expiringSoon, expired }

/// A warranty counts as expiring this many days before it ends. The
/// reminder job uses the same threshold, so they can never disagree.
const int kWarrantyWarnDays = 30;

/// Adds whole months, clamping to the last day of the target month.
///
/// Plain `DateTime(y, m + n, d)` overflows instead: 31 January plus one
/// month becomes 3 March, which skips February altogether and is not
/// even monotonic.
DateTime addMonthsClamped(DateTime start, int months) {
  final total = start.month - 1 + months;
  final year = start.year + total ~/ 12;
  final month = total % 12 + 1;
  // Day zero of the next month is the last day of this one.
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, start.day < lastDay ? start.day : lastDay);
}

/// The last day the warranty covers, inclusive.
DateTime warrantyEndOf(DateTime purchase, int amount, WarrantyUnit unit) =>
    addMonthsClamped(
      purchase,
      unit == WarrantyUnit.years ? amount * 12 : amount,
    );

/// Whole days between two calendar dates.
///
/// Counted in UTC because a local day is 23 or 25 hours long around the
/// daylight saving switch, which makes `difference().inDays` lose a day.
int daysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

/// 0.0 on the purchase date, 1.0 once the warranty is over.
///
/// Always a finite value within [0, 1]: a progress bar asserts on
/// anything else, and a malformed document must not crash the list.
double warrantyProgress(DateTime start, DateTime end, DateTime now) {
  final total = daysBetween(start, end);
  if (total <= 0) return 1;
  return (daysBetween(start, now) / total).clamp(0, 1).toDouble();
}

WarrantyStatus warrantyStatusOf(int daysLeft) {
  if (daysLeft < 0) return WarrantyStatus.expired;
  return daysLeft <= kWarrantyWarnDays
      ? WarrantyStatus.expiringSoon
      : WarrantyStatus.active;
}

/// Months run 1 to 12 — two years are entered as years, not 24 months —
/// and years start at 1.
bool isValidWarrantyAmount(int? amount, WarrantyUnit unit) {
  if (amount == null || amount < 1) return false;
  return unit == WarrantyUnit.years || amount <= 12;
}
