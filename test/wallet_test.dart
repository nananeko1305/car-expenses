import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:flutter_test/flutter_test.dart';

Repair _repair(
  int minor, {
  bool toWallet = true,
  Currency c = Currency.rsd,
  String performedBy = 'u1',
}) => Repair(
  id: 'r$minor',
  ownerId: 'u1',
  performedBy: performedBy,
  vehicleId: 'v1',
  date: DateTime(2026, 9, minor % 28 + 1),
  amountMinor: minor,
  currency: c,
  description: 'service',
  toWallet: toWallet,
);

WalletEntry _entry(
  WalletEntryType type,
  int minor, {
  Currency c = Currency.rsd,
}) => WalletEntry(
  id: 'e$minor',
  type: type,
  amountMinor: minor,
  currency: c,
  description: 'x',
  date: DateTime(2026, 9, 15),
  userId: 'u1',
  createdBy: 'u1',
);

void main() {
  test('service income is credited to whoever did the service', () {
    final m = WalletMovement.merge([
      _repair(10000, performedBy: 'u2'),
    ], const []);
    expect(m.single.userId, 'u2');
  });

  test('services add to the balance only when toWallet is set', () {
    final m = WalletMovement.merge([
      _repair(10000),
      _repair(5000, toWallet: false),
    ], const []);
    expect(m, hasLength(1));
    expect(WalletMovement.balances(m), {Currency.rsd: 10000});
  });

  test('deposits add, withdrawals subtract, currencies stay separate', () {
    final m = WalletMovement.merge(
      [_repair(10000), _repair(2000, c: Currency.eur)],
      [
        _entry(WalletEntryType.deposit, 3000),
        _entry(WalletEntryType.withdrawal, 4500),
        _entry(WalletEntryType.withdrawal, 500, c: Currency.eur),
      ],
    );
    expect(WalletMovement.balances(m), {
      Currency.rsd: 10000 + 3000 - 4500,
      Currency.eur: 2000 - 500,
    });
  });

  test('balance can go negative and history is newest first', () {
    final m = WalletMovement.merge(
      [_repair(100)],
      [_entry(WalletEntryType.withdrawal, 900)],
    );
    expect(WalletMovement.balances(m)[Currency.rsd], -800);
    for (var i = 1; i < m.length; i++) {
      expect(m[i - 1].date.isBefore(m[i].date), isFalse);
    }
  });
}
