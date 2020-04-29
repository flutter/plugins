import 'dart:async';
import 'dart:io';

import 'package:e2e/common.dart' as e2e;
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final String jsonResult =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  final e2e.Response response = e2e.Response.fromJson(jsonResult);
  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}
