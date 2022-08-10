import 'dart:io';

final Map<String, int> failedTests = <String, int>{};

const int runCount = 5;

void main() async {
  for (int i = 0; i < runCount; i++) {
    final Process process = await Process.start(
      '/Users/bmparr/Development/flutter/bin/flutter',
      '--no-color test -d emulator-5554 --timeout 240s integration_test/webview_flutter_test.dart'
          .split(' '),
    );

    process.stdout.forEach((List<int> data) {
      stdout.add(data);
      final String output = String.fromCharCodes(data);

      //00:43 +1 -2: test 3 [E]
      if (output.contains('[E]')) {
        final String? testName = RegExp(
          r'(?<=\d+:\d+ [0-9\+\-\s]+: ).+(?= \[E\])',
        ).stringMatch(output);

        if (testName == null) {
          print('FAILED TO PARSE TEST NAME: $output');
        } else {
          failedTests.putIfAbsent(testName, () => 0);
          failedTests[testName] = failedTests[testName]! + 1;
        }
      }
    });
    process.stderr.forEach((List<int> data) {
      stderr.add(data);
    });
    await process.exitCode;

    print('CURRENT TEST FAILURE COUNTS:');
    print(failedTests);
  }
}
