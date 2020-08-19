import 'dart:convert';

import 'package:e2e/e2e.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final E2EWidgetsFlutterBinding binding =
      E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('passing test', (WidgetTester tester) async {
    expect(true, true);
  });

  testWidgets('failing test', (WidgetTester tester) async {
    expect(true, false);
  });

  tearDownAll(() {
    print(
        'E2EWidgetsFlutterBinding test results: ${jsonEncode(binding.results)}');
  });
}
