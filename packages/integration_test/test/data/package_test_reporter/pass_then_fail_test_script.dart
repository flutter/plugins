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
  testWidgets('passing test', (WidgetTester tester) async {
    expect(true, true);
  });

  testWidgets('failing test', (WidgetTester tester) async {
    expect(true, false);
  });
}
