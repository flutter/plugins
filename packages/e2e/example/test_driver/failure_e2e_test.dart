import 'dart:async';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('fails gracefully', () async {
    final FlutterDriver driver = await FlutterDriver.connect();
    final String result =
        await driver.requestData(null, timeout: const Duration(minutes: 1));
    await driver.close();
    expect(
      result,
      'failure',
      skip: true, // https://github.com/flutter/flutter/issues/48601
    );
  });
}
