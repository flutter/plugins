import 'dart:async';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final FlutterDriver driver = await FlutterDriver.connect();
  await integrationDriver(
    driver: driver,
    onScreenshot: (String screenshotName, List<int> screenshotBytes) async {
      if(screenshotName == 'platform_name_2') {
        return false;
      }
      // The screenshot is saved as png. Later it can be used for golden testing
      // with library of choice, such as skia_client.dart.
      final String screenshotPath =
          await _saveScreenshot(screenshotBytes, screenshotName);
      print('INFO: screenshot recorded $screenshotPath');
      return true;
    },
  );
}

/// Example method for saving the screenshot taken by the Webdriver to a `png`
/// file.
Future<String> _saveScreenshot(List<int> screenshot, String path) async {
  final File file = File('$path.png');
  if (!file.existsSync()) {
    await file.writeAsBytes(screenshot);
  }
  return '$path.png';
}
