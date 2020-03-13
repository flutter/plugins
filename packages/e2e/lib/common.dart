// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

/// An object sent from e2e back to the Flutter Driver in response to
/// `request_data` command.
class Response {
  final String _failureDetails;

  final bool _allTestsPassed;

  /// Constructor to use for positive response.
  Response.allTestsPassed()
      : this._allTestsPassed = true,
        this._failureDetails = '';

  /// Constructor for failure response.
  Response.someTestsFailed(this._failureDetails) : this._allTestsPassed = false;

  /// Whether the test ran successfully or not.
  String get result => _allTestsPassed ? 'pass' : 'fail';

  /// If the result are failures get the formatted details.
  String get failureDetails => _allTestsPassed ? '' : _failureDetails;

  /// Convert a string pass/fail result to a boolean.
  static bool testsPassed(String result) => (result == 'pass')
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
    if (testsPassed(result['result'])) {
      return Response.allTestsPassed();
    } else {
      return Response.someTestsFailed(result['failureDetails']);
    }
  }
}

/// Method for formating the test failures' details.
String formatFailures(Map<String, String> failureDetails) {
  if (failureDetails.isEmpty) {
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
