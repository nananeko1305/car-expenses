import 'package:car_expenses/models/repair.dart';
import 'package:car_expenses/models/wallet_entry.dart';
import 'package:flutter_test/flutter_test.dart';

Repair _repair(int minor, {bool toWallet = true, Currency c = Currency.rsd}) =>
    Repair(
      id: 'r$minor',
      ownerId: 'u1',
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

  group('spending cannot take the wallet below zero', () {
    final balances = {Currency.rsd: 10000, Currency.eur: 500};

    test('new spending up to the balance passes, beyond it does not', () {
      WalletEntry spend(int minor, [Currency c = Currency.rsd]) =>
          _entry(WalletEntryType.withdrawal, minor, c: c);
      expect(WalletMovement.overdraws(balances, spend(10000)), isFalse);
      expect(WalletMovement.overdraws(balances, spend(10001)), isTrue);
      // Each currency stands alone: plenty of RSD does not cover EUR.
      expect(
        WalletMovement.overdraws(balances, spend(600, Currency.eur)),
        isTrue,
      );
      expect(WalletMovement.overdraws(const {}, spend(1)), isTrue);
    });

    test('editing spending counts what it took out already', () {
      final old = _entry(WalletEntryType.withdrawal, 4000);
      expect(WalletMovement.available(balances, Currency.rsd, old: old), 14000);
      final more = _entry(WalletEntryType.withdrawal, 14000);
      final tooMuch = _entry(WalletEntryType.withdrawal, 14001);
      expect(WalletMovement.overdraws(balances, more, old: old), isFalse);
      expect(WalletMovement.overdraws(balances, tooMuch, old: old), isTrue);
    });

    test('moving spending to another currency checks that one', () {
      final old = _entry(WalletEntryType.withdrawal, 4000);
      final inEur = _entry(WalletEntryType.withdrawal, 600, c: Currency.eur);
      expect(WalletMovement.overdraws(balances, inEur, old: old), isTrue);
    });

    test('a wallet already short can still have spending corrected', () {
      final short = {Currency.rsd: -6000};
      final old = _entry(WalletEntryType.withdrawal, 4000);
      final same = _entry(WalletEntryType.withdrawal, 4000);
      final less = _entry(WalletEntryType.withdrawal, 3000);
      final more = _entry(WalletEntryType.withdrawal, 4001);
      expect(WalletMovement.overdraws(short, same, old: old), isFalse);
      expect(WalletMovement.overdraws(short, less, old: old), isFalse);
      expect(WalletMovement.overdraws(short, more, old: old), isTrue);
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
