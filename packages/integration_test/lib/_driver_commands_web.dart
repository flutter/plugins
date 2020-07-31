// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

/// Manager for sending [WebDriverAction]s to driver side.
///
/// See: [WebDriverCommandManager].
DriverCommandManager get driverCommandManager =>
    _singletonWebDriverCommandManager;

/// WebDriverCommandManager singleton.
final WebDriverCommandManager _singletonWebDriverCommandManager =
    WebDriverCommandManager();

/// Enables Web Driver commands for `integration_tests`.
///
/// Manages communication between `integration_tests` and the `driver_tests`.
///
/// Tests can execute an Web Driver actions such as `screenshot` using browsers'
/// WebDriver APIs.
///
/// See: https://www.w3.org/TR/webdriver/
class WebDriverCommandManager extends DriverCommandManager {
  /// Tests will put the action requests from WebDriver to this pipe.
  Completer<WebDriverAction> webDriverActionPipe = Completer<WebDriverAction>();

  /// Updated when WebDriver completes the request by the test method.
  ///
  /// For example, a test method will ask for a screenshot by calling
  /// `takeScreenshot`. When this screenshot is taken [driverActionComplete]
  /// will complete.
  Completer<bool> driverActionComplete = Completer<bool>();

  /// Takes screenshot using WebDriver screenshot command.
  ///
  /// Only works on Web when tests are run via `flutter driver` command.
  ///
  /// See: https://www.w3.org/TR/webdriver/#screen-capture
  Future<void> takeScreenshot(String screenshot_name) async {
    await _webDriverCommand(WebDriverAction.screenshot(screenshot_name));
  }

  Future<void> _webDriverCommand(WebDriverAction command) async {
    try {
      webDriverActionPipe.complete(Future.value(command));
      try {
        final bool awaitCommand = await driverActionComplete.future;
        if (!awaitCommand) {
          throw Exception('Web Driver Command failed: ${command.type}');
        }
      } catch (e) {
        throw Exception(
            'Web Driver Command failed: ${command.type} with ' 'exception $e');
      }
    } finally {
      // Reset the completer and release the lock.
      driverActionComplete = Completer<bool>();
    }
  }

  /// The callback function to response the driver side input.
  ///
  /// Provides a handshake mechanism for executing [WebDriverAction]s on the
  /// driver side.
  Future<Map<String, dynamic>> callbackWithDriverCommands(
      Map<String, String> params, IntegrationTestResults testRunner) async {
    final String command = params['command'];
    Map<String, String> response;
    switch (command) {
      case 'request_data':
        return params['message'] == null
            ? _requestData(testRunner)
            : _requestDataWithMessage(params['message'], testRunner);
        break;
      case 'get_health':
        response = <String, String>{'status': 'ok'};
        break;
      default:
        throw UnimplementedError('$command is not implemented');
    }
    return <String, dynamic>{
      'isError': false,
      'response': response,
    };
  }

  Future<Map<String, dynamic>> _requestDataWithMessage(
      String extraMessage, IntegrationTestResults testRunner) async {
    // Test status is added as an exta message.
    Map<String, String> response;
    // If Test status is `wait_on_webdriver_command` send the first
    // command in the `commandPipe` to the tests.
    if (extraMessage == '${TestStatus.waitOnWebdriverCommand}') {
      final WebDriverAction action = await webDriverActionPipe.future;
      switch (action.type) {
        case WebDriverActionTypes.screenshot:
          final Map<String, dynamic> data = Map.from(action.values);
          data.addAll(
              WebDriverAction.typeToMap(WebDriverActionTypes.screenshot));
          response = <String, String>{
            'message': Response.webDriverCommand(data: data).toJson(),
          };
          break;
        case WebDriverActionTypes.noop:
          final Map<String, dynamic> data = Map();
          data.addAll(WebDriverAction.typeToMap(WebDriverActionTypes.noop));
          response = <String, String>{
            'message': Response.webDriverCommand(data: data).toJson(),
          };
          break;
        default:
          throw UnimplementedError('${action.type} is not implemented');
      }
    }
    // Tests will send `webdriver_command_complete` status after
    // WebDriver completes an action.
    else if (extraMessage == '${TestStatus.webdriverCommandComplete}') {
      final Map<String, dynamic> data = Map();
      data.addAll(WebDriverAction.typeToMap(WebDriverActionTypes.ack));
      response = <String, String>{
        'message': Response.webDriverCommand(data: data).toJson(),
      };
      driverActionComplete.complete(Future.value(true));
      webDriverActionPipe = Completer<WebDriverAction>();
    } else {
      throw UnimplementedError('$extraMessage is not implemented');
    }
    return <String, dynamic>{
      'isError': false,
      'response': response,
    };
  }

  Future<Map<String, dynamic>> _requestData(
      IntegrationTestResults testRunner) async {
    final bool allTestsPassed = await testRunner.allTestsPassed.future;
    final Map<String, String> response = <String, String>{
      'message': allTestsPassed
          ? Response.allTestsPassed(data: testRunner.reportData).toJson()
          : Response.someTestsFailed(
              testRunner.failureMethodsDetails,
              data: testRunner.reportData,
            ).toJson(),
    };
    return <String, dynamic>{
      'isError': false,
      'response': response,
    };
  }

  @override
  void cleanup() {
    if (!webDriverActionPipe.isCompleted) {
      webDriverActionPipe
          .complete(Future<WebDriverAction>.value(WebDriverAction.noop()));
    }

    if (!driverActionComplete.isCompleted) {
      driverActionComplete.complete(Future<bool>.value(false));
    }
  }
}
