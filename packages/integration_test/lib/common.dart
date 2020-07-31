// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

/// Classes shared between `integration_test.dart` and `flutter drive` based
/// adoptor (ex: `integration_test_driver.dart`).

/// An object sent from integration_test back to the Flutter Driver in response to
/// `request_data` command.
class Response {
  final List<Failure> _failureDetails;

  final bool _allTestsPassed;

  /// The extra information to be added along side the test result.
  Map<String, dynamic> data;

  /// Constructor to use for positive response.
  Response.allTestsPassed({this.data})
      : this._allTestsPassed = true,
        this._failureDetails = null;

  /// Constructor for failure response.
  Response.someTestsFailed(this._failureDetails, {this.data})
      : this._allTestsPassed = false;

  /// Constructor for failure response.
  Response.toolException({String ex})
      : this._allTestsPassed = false,
        this._failureDetails = [Failure('ToolException', ex)];

  /// Constructor for web driver commands response.
  Response.webDriverCommand({this.data})
      : this._allTestsPassed = false,
        this._failureDetails = null;

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
        if (data != null) 'data': data
      });

  /// Deserializes the result from JSON.
  static Response fromJson(String source) {
    final Map<String, dynamic> responseJson = json.decode(source);
    if (responseJson['result'] as String == 'true') {
      return Response.allTestsPassed(data: responseJson['data']);
    } else {
      return Response.someTestsFailed(
        _failureDetailsFromJson(responseJson['failureDetails']),
        data: responseJson['data'],
      );
    }
  }

  /// Method for formatting the test failures' details.
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
      list.add(f.toJson());
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
  String toJson() {
    return json.encode(<String, String>{
      'methodName': methodName,
      'details': details,
    });
  }

  @override
  String toString() => toJson();

  /// Decode a JSON string to create a Failure object.
  static Failure fromJsonString(String jsonString) {
    Map<String, dynamic> failure = json.decode(jsonString);
    return Failure(failure['methodName'], failure['details']);
  }
}

/// Integration web tests can execute WebDriver actions such as screenshots.
///
/// These test will use [TestStatus] to notify `integration_test` of their
/// state.
enum TestStatus {
  /// Test is waiting for executing WebDriver actions.
  waitOnWebdriverCommand,

  /// Test executed the previously requested action.
  webdriverCommandComplete,
}

/// Types of different WebDriver actions that can be used in web integration
/// tests.
///
/// These actions are either commands that WebDriver can execute or used
/// for the communication between `integration_test` and the driver test.
enum WebDriverActionTypes {
  /// Acknowlegement for the previously sent message.
  ack,

  /// No further WebDriver Action is necessary.
  noop,

  /// Asking WebDriver to take a screenshot of the Web page.
  screenshot,
}

/// Command for WebDriver to execute.
///
/// Only works on Web when tests are run via `flutter driver` command.
///
/// See: https://www.w3.org/TR/webdriver/
class WebDriverAction {
  /// Type of the [WebDriverAction].
  ///
  /// Currently the only action that triggers a WebDriver API command is
  /// `screenshot`.
  ///
  /// There are also `ack` and `noop` actions defined to manage the handshake
  /// during the communication.
  final WebDriverActionTypes type;

  /// Used for adding extra values to the actions such as file name for
  /// `screenshot`.
  final Map<String, dynamic> values;

  /// Constructor for [WebDriverActionTypes.noop] action.
  WebDriverAction.noop()
      : this.type = WebDriverActionTypes.noop,
        this.values = Map();

  /// Constructor for [WebDriverActionTypes.noop] screenshot.
  WebDriverAction.screenshot(String screenshot_name)
      : this.type = WebDriverActionTypes.screenshot,
        this.values = {'screenshot_name': screenshot_name};

  /// Util method for converting [WebDriverActionTypes] to a map entry.
  ///
  /// Used for converting messages to json format.
  static Map<String, dynamic> typeToMap(WebDriverActionTypes type) => {
        'web_driver_action': '${type}',
      };
}

/// Template methods to implement for any class which manages communication
/// between `integration_tests` and the `driver_tests`.
///
/// See example [WebDriverCommandManager].
abstract class DriverCommandManager {
  /// The callback function to response the driver side input which can also
  /// send WebDriver command requests such as `screenshot` to driver side.
  Future<Map<String, dynamic>> callbackWithDriverCommands(
      Map<String, String> params, IntegrationTestResults testRunner);

  /// Request to take a screenshot of the application from the driver side.
  void takeScreenshot(String screenshot);

  /// Cleanup and completers or locks used during the communication.
  void cleanup();
}

/// Interface that surfaces test results of integration tests.
///
/// Implemented by [IntegrationTestWidgetsFlutterBinding]s.
///
/// Any class which needs to access the test results but do not want to create
/// a cyclic dependency [IntegrationTestWidgetsFlutterBinding]s can use this
/// interface. Example [WebDriverCommandManager].
abstract class IntegrationTestResults {
  /// Stores failure details.
  ///
  /// Failed test method's names used as key.
  List<Failure> get failureMethodsDetails;

  /// The extra data for the reported result.
  Map<String, dynamic> get reportData;

  /// Whether all the test methods completed succesfully.
  Completer<bool> get allTestsPassed;
}
