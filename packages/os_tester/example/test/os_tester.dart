import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:os_tester_example/main.dart' as app;
import 'package:os_tester/os_tester.dart';

void main() {
  test('OSTester Example App', () async {
    app.main();
    // TODO(jackson): Implement wait() on OS side. For now we can use Dart to wait.
    await Future<void>.delayed(const Duration(seconds: 5));
//
    await os.tap(os.label('Done'));
    await os.expect(os.label('TEST'), os.visible);

    runApp(MaterialApp(home: Text('pass')));
  });
}
