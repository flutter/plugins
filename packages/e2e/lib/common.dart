// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

/// An object sent from e2e back to the Flutter Driver in response to
/// `request_data` command.
class Response {
  String _failureDetails;

  final bool _allTestsPassed;

  /// Constructor which receives tests results' flag and failure details.
  Response(this._allTestsPassed, String failureDetails) {
    this._failureDetails = failureDetails;
  }

  /// Whether the test run successfully or not.
  String get result => _allTestsPassed ? 'pass' : 'fail';

  /// If the result are failures get the formatted details.
  String get failureDetails => _allTestsPassed ? '' : _failureDetails;

  /// Convert a string pass/fail result to a boolean.
  static bool allTestsPassed(String result) => (result == 'pass')
      ? true
      : (result == 'fail') ? false : throw 'Invalid State for result.';

  /// Serializes this message to a JSON map.
  String toJson() => json.encode(<String, String>{
        'result': result,
        'failureDetails': _failureDetails,
      });

  /// Deserializes the result from JSON.
  static Response fromJson(String source) {
    Map<String, dynamic> result = json.decode(source);
    return Response(allTestsPassed(result['result']), result['failureDetails']);
  }
}

/// Method for formating the test failures' details.
String formatFailures(Map<String, String> failureDetails) {
  if(failureDetails.isEmpty) {
    return '';
  }
  StringBuffer sb = StringBuffer();
  int failureCount = 1;
  failureDetails.forEach((methodName, details) {
    sb.writeln('Failure in method: $methodName');
    sb.writeln('$details');
    sb.writeln('end of failure ${failureCount.toString()}\n\n');
    failureCount++;
  });
  return sb.toString();
}
