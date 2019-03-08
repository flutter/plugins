import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:os_tester_example/main.dart' as app;
import 'package:os_tester/os_tester.dart';

void main() {
  test('OSTester Example App', () async {
    app.main();
    // TODO(jackson): Teach EarlGrey to wait for Flutter to finish rendering
    // so we don't have to wait here.
    await Future<void>.delayed(const Duration(seconds: 1));
    await os.tap(os.label('TEST'));
    await os.expect(os.label('pass'), os.visible);
  });
}
