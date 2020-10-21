import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() async {
  await run(_testMain);

  final IntegrationTestWidgetsFlutterBinding binding =
      WidgetsBinding.instance as IntegrationTestWidgetsFlutterBinding;
  print(
      'IntegrationTestWidgetsFlutterBinding test results: ${jsonEncode(binding.results)}');
}

void _testMain() {
  testWidgets('failing testWidgets()', (WidgetTester tester) async {
    expect(true, false);
  });

  test('failing test()', () {
    expect(true, false);
  });
}
