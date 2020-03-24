import 'dart:async';
import 'dart:io';

import 'package:e2e/common.dart' as e2ecommon;
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final String jsonResult =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  final e2ecommon.Response response = e2ecommon.Response.fromJson(jsonResult);
  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}
