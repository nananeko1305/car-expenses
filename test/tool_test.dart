import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/tool.dart';
import 'package:car_expenses/models/warranty.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Tool _tool({
  int warrantyAmount = 2,
  WarrantyUnit unit = WarrantyUnit.years,
  int? amountMinor = 1500000,
  String entryId = 'e1',
}) => Tool(
  id: 't1',
  ownerId: 'u1',
  name: 'Udarni odvijač',
  purchaseDate: DateTime(2026, 9, 24),
  warrantyAmount: warrantyAmount,
  warrantyUnit: unit,
  amountMinor: amountMinor,
  currency: amountMinor == null ? null : Currency.rsd,
  entryId: entryId,
);

void main() {
  test('the warranty runs from the purchase date', () {
    expect(_tool().warrantyEnd, DateTime(2028, 9, 24));
    expect(
      _tool(warrantyAmount: 6, unit: WarrantyUnit.months).warrantyEnd,
      DateTime(2027, 3, 24),
    );
  });

  test('the last covered day is still under warranty', () {
    final tool = _tool();
    expect(tool.daysLeft(DateTime(2028, 9, 24)), 0);
    expect(tool.status(DateTime(2028, 9, 24)), WarrantyStatus.expiringSoon);
    expect(tool.daysLeft(DateTime(2028, 9, 25)), -1);
    expect(tool.status(DateTime(2028, 9, 25)), WarrantyStatus.expired);
    expect(tool.progress(DateTime(2028, 9, 25)), 1);
  });

  test('a tool bought outside the wallet has no price and no entry', () {
    final tool = _tool(amountMinor: null, entryId: '');
    expect(tool.amountMinor, isNull);
    expect(tool.currency, isNull);
    expect(tool.toMap()['amountMinor'], isNull);
    expect(tool.daysLeft(DateTime(2027, 9, 24)), 366);
  });

  group('toMap', () {
    test('mirrors the computed end date for the reminder job', () {
      final tool = _tool();
      expect(
        tool.toMap()['warrantyEndsAt'],
        Timestamp.fromDate(tool.warrantyEnd),
      );
    });

    // The security rules list these keys by hand; nothing else ties the
    // two together.
    test('writes exactly the fields the rules validate', () {
      expect(_tool().toMap().keys.toSet(), {
        'ownerId',
        'name',
        'purchaseDate',
        'warrantyAmount',
        'warrantyUnit',
        'warrantyEndsAt',
        'amountMinor',
        'currency',
        'entryId',
        'receiptUrl',
        'notify',
        'archived',
        'updatedAt',
      });
    });

    // The reminder job owns that field, and update() only touches the
    // keys it is given — so the app must never send it.
    test('leaves the reminder bookkeeping alone', () {
      expect(_tool().toMap().containsKey('remindersSent'), isFalse);
    });
  });
}
