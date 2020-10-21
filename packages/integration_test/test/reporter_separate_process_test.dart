import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

// Assumes that the flutter command is in `$PATH`.
const String _flutterBin = 'flutter';
const String _integrationResultsPrefix =
    'IntegrationTestWidgetsFlutterBinding test results: ';
const String _failureExcerpt = 'Expected: <false>\\n  Actual: <true>';

void main() async {
  group('With the package:test reporter', () {
    test('when multiple tests pass', () async {
      final Map<String, dynamic> results = await _runTest(
          'test/data/package_test_reporter/pass_test_script.dart');

      expect(
          results,
          equals({
            'passing testWidgets()': 'success',
            'passing test()': 'success',
          }));
    });

    test('when multiple tests fail', () async {
      final Map<String, dynamic> results = await _runTest(
          'test/data/package_test_reporter/fail_test_script.dart');

      expect(results, hasLength(2));
      expect(results,
          containsPair('failing testWidgets()', contains(_failureExcerpt)));
      expect(
          results, containsPair('failing test()', contains(_failureExcerpt)));
    });

    test('when one test passes, then another fails', () async {
      final Map<String, dynamic> results = await _runTest(
          'test/data/package_test_reporter/pass_then_fail_test_script.dart');

      expect(results, hasLength(2));
      expect(results, containsPair('passing test', equals('success')));
      expect(results, containsPair('failing test', contains(_failureExcerpt)));
    });
  });
  group('With the legacy reporter', () {
    test('when multiple tests pass', () async {
      final Map<String, dynamic> results =
          await _runTest('test/data/legacy_reporter/pass_test_script.dart');

      expect(
          results,
          equals({
            'passing test 1': 'success',
            'passing test 2': 'success',
          }));
    });

    test('when multiple tests fail', () async {
      final Map<String, dynamic> results =
          await _runTest('test/data/legacy_reporter/fail_test_script.dart');

      expect(results, hasLength(2));
      expect(
          results, containsPair('failing test 1', contains(_failureExcerpt)));
      expect(
          results, containsPair('failing test 2', contains(_failureExcerpt)));
    });

    test('when one test passes, then another fails', () async {
      final Map<String, dynamic> results = await _runTest(
          'test/data/legacy_reporter/pass_then_fail_test_script.dart');

      expect(results, hasLength(2));
      expect(results, containsPair('passing test', equals('success')));
      expect(results, containsPair('failing test', contains(_failureExcerpt)));
    });
  });
}

/// Runs a test script and returns the [IntegrationTestWidgetsFlutterBinding.result].
///
/// [scriptPath] is relative to the package root.
Future<Map<String, dynamic>> _runTest(String scriptPath) async {
  final Process process =
      await Process.start(_flutterBin, ['test', scriptPath]);

  /// In the test [tearDownAll] block, the test results are encoded into JSON and
  /// are printed with the [_integrationResultsPrefix] prefix.
  ///
  /// See the following for the test event spec which we parse the printed lines
  /// out of: https://github.com/dart-lang/test/blob/master/pkgs/test/doc/json_reporter.md
  final String testResults = (await process.stdout
          .transform(utf8.decoder)
          .expand((String text) => text.split('\n'))
          .firstWhere(
              (String message) => message.contains(_integrationResultsPrefix)))
      .replaceAll(RegExp('.*${_integrationResultsPrefix}'), '');
  // print(testResults);
  return jsonDecode(testResults);
}
