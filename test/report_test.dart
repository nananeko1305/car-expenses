import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/report.dart';
import 'package:car_expenses/models/tool.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:car_expenses/models/warranty.dart';
import 'package:flutter_test/flutter_test.dart';

final _oct = DateTime(2026, 10);

Repair _repair(
  int minor,
  DateTime date, {
  String vehicleId = 'v1',
  bool toWallet = true,
  Currency c = Currency.rsd,
}) => Repair(
  id: 'r$minor',
  ownerId: 'u1',
  vehicleId: vehicleId,
  date: date,
  amountMinor: minor,
  currency: c,
  description: 'service',
  toWallet: toWallet,
);

WalletEntry _entry(
  String id,
  WalletEntryType type,
  int minor,
  DateTime date, {
  Currency c = Currency.rsd,
}) => WalletEntry(
  id: id,
  type: type,
  amountMinor: minor,
  currency: c,
  description: 'x',
  date: date,
  userId: 'u1',
  createdBy: 'u1',
);

Tool _tool(DateTime date, {String entryId = '', int? minor, Currency? c}) =>
    Tool(
      id: 't$entryId$minor',
      ownerId: 'u1',
      name: 'drill',
      purchaseDate: date,
      warrantyAmount: 2,
      warrantyUnit: WarrantyUnit.years,
      amountMinor: minor,
      currency: c,
      entryId: entryId,
    );

void main() {
  test('counts the month\'s services and the different cars in them', () {
    final r = Report.of(
      month: _oct,
      repairs: [
        _repair(100, DateTime(2026, 10, 1), vehicleId: 'a'),
        _repair(200, DateTime(2026, 10, 31, 23, 59), vehicleId: 'a'),
        _repair(300, DateTime(2026, 10, 15), vehicleId: 'b'),
        _repair(400, DateTime(2026, 9, 30, 23, 59), vehicleId: 'c'),
        _repair(500, DateTime(2026, 11, 1), vehicleId: 'd'),
      ],
    );
    expect(r.services, 3);
    expect(r.cars, 2);
    expect(r.earned, {Currency.rsd: 600});
  });

  test('a service earns even when its money skipped the wallet', () {
    final r = Report.of(
      month: _oct,
      repairs: [
        _repair(100, DateTime(2026, 10, 2), toWallet: false),
        _repair(50, DateTime(2026, 10, 3), c: Currency.eur),
      ],
    );
    expect(r.earned, {Currency.rsd: 100, Currency.eur: 50});
  });

  test('deposits are other income, spending is costs, net is the rest', () {
    final r = Report.of(
      month: _oct,
      repairs: [_repair(10000, DateTime(2026, 10, 5))],
      entries: [
        _entry('d', WalletEntryType.deposit, 3000, DateTime(2026, 10, 6)),
        _entry('w', WalletEntryType.withdrawal, 4500, DateTime(2026, 10, 7)),
        _entry('old', WalletEntryType.withdrawal, 999, DateTime(2026, 9, 7)),
      ],
    );
    expect(r.otherIncome, {Currency.rsd: 3000});
    expect(r.costs, {Currency.rsd: 4500});
    expect(r.net, {Currency.rsd: 10000 + 3000 - 4500});
  });

  test('a tool bought from the wallet is part of the costs, once', () {
    final r = Report.of(
      month: _oct,
      repairs: const [],
      entries: [
        _entry('w', WalletEntryType.withdrawal, 7000, DateTime(2026, 10, 9)),
        _entry('fuel', WalletEntryType.withdrawal, 1000, DateTime(2026, 10, 9)),
      ],
      // The receipt date differs, and the copied price is stale: the
      // wallet entry decides both.
      tools: [
        _tool(DateTime(2026, 9, 30), entryId: 'w', minor: 1, c: Currency.eur),
      ],
    );
    expect(r.tools, {Currency.rsd: 7000});
    expect(r.costs, {Currency.rsd: 8000});
  });

  test('a tool paid outside the wallet adds to the costs', () {
    final r = Report.of(
      month: _oct,
      repairs: const [],
      tools: [
        _tool(DateTime(2026, 10, 3), minor: 2500, c: Currency.eur),
        // Its spending was deleted: the tool's own copy stands in.
        _tool(
          DateTime(2026, 10, 4),
          entryId: 'gone',
          minor: 100,
          c: Currency.rsd,
        ),
        _tool(DateTime(2026, 10, 5)), // no price recorded
        _tool(DateTime(2026, 9, 5), minor: 900, c: Currency.rsd),
      ],
    );
    expect(r.tools, {Currency.eur: 2500, Currency.rsd: 100});
    expect(r.costs, r.tools);
  });

  test('without a month the report covers all time', () {
    final r = Report.of(
      repairs: [
        _repair(100, DateTime(2025, 1, 1), vehicleId: 'a'),
        _repair(200, DateTime(2026, 10, 1), vehicleId: 'b'),
      ],
    );
    expect(r.services, 2);
    expect(r.cars, 2);
    expect(r.earned, {Currency.rsd: 300});
  });

  test('span runs from the oldest record to now or the newest', () {
    final now = DateTime(2026, 10, 6);
    expect(Report.span(now: now, repairs: [], entries: [], tools: []), (
      first: _oct,
      last: _oct,
    ));
    final s = Report.span(
      now: now,
      repairs: [_repair(1, DateTime(2026, 12, 2))],
      entries: [_entry('e', WalletEntryType.deposit, 1, DateTime(2026, 3, 20))],
      tools: [_tool(DateTime(2025, 11, 30))],
    );
    expect(s, (first: DateTime(2025, 11), last: DateTime(2026, 12)));
  });
}
