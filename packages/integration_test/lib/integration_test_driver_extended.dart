import 'dart:async';
import 'dart:io';

import 'common.dart';

import 'package:flutter_driver/flutter_driver.dart';

/// Example Integration Test which can also run WebDriver command depending on
/// the requests coming from the test methods.
Future<void> integrationDriver() async {
  final FlutterDriver driver = await FlutterDriver.connect();

  // Test states that it's waiting on web driver commands.
  String jsonResponse = await driver.requestData(
      '${TestStatus.waitOnWebdriverCommand}',
      timeout: const Duration(seconds: 10));

  Response response = Response.fromJson(jsonResponse);

  // Until `integration_test` returns a [WebDriverCommandType.noop], keep
  // executing WebDriver commands.
  while (response.data != null &&
      response.data['web_driver_command'] != null &&
      response.data['web_driver_command'] != '${WebDriverCommandType.noop}') {
    final String webDriverCommand = response.data['web_driver_command'];
    if (webDriverCommand == '${WebDriverCommandType.screenshot}') {
      // Use `driver.screenshot()` method to get a screenshot of the web page.
      final List<int> screenshotImage = await driver.screenshot();
      final String screenshotName = response.data['screenshot_name'];

      // The screenshot is saved as png. Later it can be used for golden testing
      // with library of choice, such as skia_client.dart.
      final String screenshotPath =
          await _saveScreenshot(screenshotImage, screenshotName);
      print('INFO: screenshot recorded $screenshotPath');

      jsonResponse = await driver.requestData(
          '${TestStatus.webdriverCommandComplete}',
          timeout: const Duration(seconds: 10));

      response = Response.fromJson(jsonResponse);
    } else if (webDriverCommand == '${WebDriverCommandType.ack}') {
      // Previous command completed ask for a new one.
      jsonResponse = await driver.requestData(
          '${TestStatus.waitOnWebdriverCommand}',
          timeout: const Duration(seconds: 10));

      response = Response.fromJson(jsonResponse);
    } else {
      break;
    }
  }

  // If No-op command is sent, ask for the result of all tests.
  if (response.data != null &&
      response.data['web_driver_command'] != null &&
      response.data['web_driver_command'] == '${WebDriverCommandType.noop}') {
    jsonResponse =
        await driver.requestData(null, timeout: const Duration(minutes: 1));

    response = Response.fromJson(jsonResponse);
    print('result $jsonResponse');
  }

  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
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
