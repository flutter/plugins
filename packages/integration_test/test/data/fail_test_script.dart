import 'dart:convert';

import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized()
          as IntegrationTestWidgetsFlutterBinding;

  testWidgets('failing test 1', (WidgetTester tester) async {
    expect(true, false);
  });

  testWidgets('failing test 2', (WidgetTester tester) async {
    expect(true, false);
  });

  tearDownAll(() {
    print(
        'IntegrationTestWidgetsFlutterBinding test results: ${jsonEncode(binding.results)}');
  });
}
