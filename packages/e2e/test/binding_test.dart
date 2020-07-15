import 'package:flutter/material.dart';

import 'package:e2e/e2e.dart';
import 'package:e2e/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  Future<Map<String, dynamic>> request;

  group('Test E2E binding', () {
    final WidgetsBinding binding = E2EWidgetsFlutterBinding.ensureInitialized();
    assert(binding is E2EWidgetsFlutterBinding);
    final E2EWidgetsFlutterBinding e2ebinding =
        binding as E2EWidgetsFlutterBinding;

    setUp(() {
      request = e2ebinding.callback(<String, String>{
        'command': 'request_data',
      });
    });

    testWidgets('Run E2E app', (WidgetTester tester) async {
      runApp(MaterialApp(
        home: Text('Test'),
      ));
      expect(tester.binding, e2ebinding);
      e2ebinding.reportData = <String, dynamic>{'answer': 42};
    });
  });

  tearDownAll(() async {
    // This part is outside the group so that `request` has been compeleted as
    // part of the `tearDownAll` registerred in the group during
    // `E2EWidgetsFlutterBinding` initialization.
    final Map<String, dynamic> response =
        (await request)['response'] as Map<String, dynamic>;
    final String message = response['message'] as String;
    Response result = Response.fromJson(message);
    assert(result.data['answer'] == 42);
  });
}
