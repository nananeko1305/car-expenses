import 'package:car_expenses/models/vehicle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const golf = Vehicle(
    id: '1',
    ownerId: 'u',
    name: 'VW Golf',
    plate: 'BG-123-AB',
  );
  const skoda = Vehicle(
    id: '2',
    ownerId: 'u',
    name: 'Škoda',
    plate: 'NI 045-ŠĐ',
  );

  test('plate search ignores case, spaces and dashes', () {
    for (final q in ['bg123ab', 'BG-123', ' 123 ab', '123-AB', '']) {
      expect(golf.matches(q), isTrue, reason: q);
    }
    expect(golf.matches('NI'), isFalse);
  });

  test('Serbian letters in plates are matched', () {
    expect(skoda.matches('045šđ'), isTrue);
    expect(skoda.matches('ni045'), isTrue);
  });

  test('name matches too', () {
    expect(golf.matches('golf'), isTrue);
    expect(skoda.matches('škoda'), isTrue);
  });
}
