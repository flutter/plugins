// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

/// An object sent from e2e back to the Flutter Driver in response to
/// `request_data` command.
class Response {
  final Map<String, dynamic> _failureDetails;

  final bool _allTestsPassed;

  /// Constructor to use for positive response.
  Response.allTestsPassed()
      : this._allTestsPassed = true,
        this._failureDetails = null;

  /// Constructor for failure response.
  Response.someTestsFailed(this._failureDetails) : this._allTestsPassed = false;

  /// Whether the test ran successfully or not.
  bool get allTestsPassed => _allTestsPassed;

  /// If the result are failures get the formatted details.
  String get formattedFailureDetails =>
      _allTestsPassed ? '' : formatFailures(_failureDetails);

  /// Failure details as a map.
  Map<String, dynamic> get failureDetails => _failureDetails;

  /// Serializes this message to a JSON map.
  String toJson() => json.encode(<String, String>{
        'result': allTestsPassed.toString(),
        'failureDetails': json.encode(_failureDetails),
      });

  /// Deserializes the result from JSON.
  static Response fromJson(String source) {
    Map<String, dynamic> result = json.decode(source);
    if (result['result'] == 'true') {
      return Response.allTestsPassed();
    } else {
      final Map<String, dynamic> failureDetailsAsMap =
          json.decode(result['failureDetails']);

      return Response.someTestsFailed(failureDetailsAsMap);
    }
  }

  /// Method for formating the test failures' details.
  String formatFailures(Map<String, dynamic> failureDetails) {
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
}
