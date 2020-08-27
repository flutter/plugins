import 'dart:async';

import 'package:integration_test/common.dart' as common;
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

Future<void> main() async {
  test('fails gracefully', () async {
    final FlutterDriver driver = await FlutterDriver.connect();
    final String jsonResult =
        await driver.requestData(null, timeout: const Duration(minutes: 1));
    common.Response response = common.Response.fromJson(jsonResult);
    await driver.close();
    expect(
      response.allTestsPassed,
      false,
    );
  });
}
