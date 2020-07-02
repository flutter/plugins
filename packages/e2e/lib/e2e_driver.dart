import 'dart:async';
import 'dart:io';

import 'package:e2e/common.dart' as e2e;
import 'package:flutter_driver/flutter_driver.dart';

Future<void> main() async => e2eDriver();

/// Adaptor to run E2E test using `flutter drive`.
///
/// For an E2E test `<test_name>.dart`, put a file named `<test_name>_test.dart`
/// in the app's `test_driver` directory:
///
/// ```dart
/// import 'dart:async';
///
/// import 'package:e2e/e2e_driver.dart' as e2e;
///
/// Future<void> main() async => e2e.e2eDriver();
///
/// ```
Future<void> e2eDriver({
  Duration timeout = const Duration(minutes: 1),
  String testName,
  bool traceTimeline = false,
}) async {

  print(testName);
  final FlutterDriver driver = await FlutterDriver.connect();
  String jsonResult;
  Timeline timeline;
  Future<void> runner() async {
    jsonResult = await driver.requestData(null, timeout: timeout);
  }
  if (traceTimeline) {
    timeline = await driver.traceAction(runner);
  }
  else {
    await runner();
  }
  final e2e.Response response = e2e.Response.fromJson(jsonResult);
  await driver.close();

  if (response.allTestsPassed) {
    print('All tests passed.');
    if (traceTimeline) {
      final TimelineSummary summary = TimelineSummary.summarize(timeline);
      await summary.writeTimelineToFile(testName, pretty: true);
      await summary.writeSummaryToFile(testName, pretty: true);
    }
    exit(0);
  } else {
    print('Failure Details:\n${response.formattedFailureDetails}');
    exit(1);
  }
}
