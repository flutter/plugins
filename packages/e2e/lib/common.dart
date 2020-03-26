// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

/// An object sent from e2e back to the Flutter Driver in response to
/// `request_data` command.
class Response {
  final List<Failure> _failureDetails;

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

  /// Failure details as a list.
  List<Failure> get failureDetails => _failureDetails;

  /// Serializes this message to a JSON map.
  String toJson() => json.encode(<String, dynamic>{
        'result': allTestsPassed.toString(),
        'failureDetails': _failureDetailsAsString(),
      });

  /// Deserializes the result from JSON.
  static Response fromJson(String source) {
    Map<String, dynamic> responseJson = json.decode(source);
    if (responseJson['result'] == 'true') {
      return Response.allTestsPassed();
    } else {
      return Response.someTestsFailed(
          _failureDetailsFromJson(responseJson['failureDetails']));
    }
  }

  /// Method for formating the test failures' details.
  String formatFailures(List<Failure> failureDetails) {
    if (failureDetails.isEmpty) {
      return '';
    }

    StringBuffer sb = StringBuffer();
    int failureCount = 1;
    failureDetails.forEach((Failure f) {
      sb.writeln('Failure in method: ${f.methodName}');
      sb.writeln('${f.details}');
      sb.writeln('end of failure ${failureCount.toString()}\n\n');
      failureCount++;
    });
    return sb.toString();
  }

  /// Create a list of Strings from [_failureDetails].
  List<String> _failureDetailsAsString() {
    final List<String> list = List<String>();
    if (_failureDetails == null || _failureDetails.isEmpty) {
      return list;
    }

    _failureDetails.forEach((Failure f) {
      list.add(f.toString());
    });

    return list;
  }

  /// Creates a [Failure] list using a json response.
  static List<Failure> _failureDetailsFromJson(List<dynamic> list) {
    final List<Failure> failureList = List<Failure>();
    list.forEach((s) {
      final String failure = s as String;
      failureList.add(Failure.fromJsonString(failure));
    });
    return failureList;
  }
}

/// Representing a failure includes the method name and the failure details.
class Failure {
  /// The name of the test method which failed.
  final String methodName;

  /// The details of the failure such as stack trace.
  final String details;

  /// Constructor requiring all fields during initialization.
  Failure(this.methodName, this.details);

  /// Serializes the object to JSON.
  @override
  String toString() {
    return json.encode(<String, String>{
      'methodName': methodName,
      'details': details,
    });
  }

  /// Decode a JSON string to create a Failure object.
  static Failure fromJsonString(String jsonString) {
    Map<String, dynamic> failure = json.decode(jsonString);
    return Failure(failure['methodName'], failure['details']);
  }
}
