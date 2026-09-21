import 'dart:convert';

import 'package:car_expenses/services/update_checker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses version.json written by the release workflow', () {
    // Same shape the workflow's heredoc produces.
    const raw =
        '{"version":"1.0.0","build":7,"url":"https://github.com/o/r/releases/latest/download/car-expenses.apk"}';
    final info = ReleaseInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(info.version, '1.0.0');
    expect(info.build, 7);
    expect(info.downloadUrl, endsWith('car-expenses.apk'));
  });
}
