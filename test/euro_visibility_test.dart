import 'package:car_expenses/services/euro_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('euros are hidden until someone turns them on', () async {
    SharedPreferences.setMockInitialValues({});
    final visibility = EuroVisibility();
    await visibility.load();
    expect(visibility.shown, isFalse);
  });

  test('the choice is kept on the device and announced', () async {
    SharedPreferences.setMockInitialValues({});
    final visibility = EuroVisibility();
    var announced = 0;
    visibility.addListener(() => announced++);

    await visibility.set(true);
    expect(visibility.shown, isTrue);
    expect(announced, 1);

    final afterRestart = EuroVisibility();
    await afterRestart.load();
    expect(afterRestart.shown, isTrue);

    await afterRestart.set(false);
    final again = EuroVisibility();
    await again.load();
    expect(again.shown, isFalse);
  });
}
