import 'dart:async';
import 'dart:io';

import 'package:e2e/common.dart' as common;
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  final String jsonResult =
      await driver.requestData(null, timeout: const Duration(minutes: 1));
  final common.Response response = common.Response.fromJson(jsonResult);
  await driver.close();

  if (response.result == 'pass') {
    exit(0);
  } else {
    print('Failure Details:\n${response.failureDetails}');
    exit(1);
  }
}
