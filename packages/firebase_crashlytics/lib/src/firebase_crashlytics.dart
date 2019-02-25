// Copyright 2019, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of firebase_crashlytics;

/// The entry point for accessing Crashlytics.
///
/// You can get an instance by calling `Crashlytics.instance`.
class Crashlytics {
  static final Crashlytics instance = Crashlytics();

  /// Set to true to have errors sent to Crashlytics while in debug mode. By
  /// default this is false.
  bool enableInDevMode = false;

  /// Keys to be included with report.
  @visibleForTesting
  final Map<String, dynamic> keys = <String, dynamic>{};

  /// Logs to be included with report.
  @visibleForTesting
  final ListQueue<String> logs = ListQueue<String>(15);
  int _logSize = 0;

  bool get isInDebugMode {
    bool _inDebugMode = false;
    if (!enableInDevMode) {
      assert(_inDebugMode = true);
    }
    return _inDebugMode;
  }

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_crashlytics');

  Future<void> onError(FlutterErrorDetails details) async {
    print('Error caught by Crashlytics plugin:');
    if (isInDebugMode && !enableInDevMode) {
      print(Trace.format(details.stack).trimRight().split('\n'));
    } else {
      // Send logs
      await sendLogs();

      // Send keys
      await sendKeys();

      // Report error
      final List<String> stackTraceLines =
          Trace.format(details.stack).trimRight().split('\n');
      final dynamic result =
          // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
          // https://github.com/flutter/flutter/issues/26431
          // ignore: strong_mode_implicit_dynamic_method
          await channel.invokeMethod('Crashlytics#onError', <String, dynamic>{
        'exception': details.exceptionAsString(),
        'stackTrace': details.stack.toString(),
        'stackTraceLines': stackTraceLines,
        'code': stackTraceLines[0].hashCode
      });
      print(result);
    }
  }

  void crash() {
    throw StateError('Error thrown by Crashlytics plugin');
  }

  /// Reports the global value for debug mode.
  /// TODO(kroikie): Clarify what this means in context of both Android and iOS.
  Future<bool> isDebuggable() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final bool result = await channel.invokeMethod('Crashlytics#isDebuggable');
    return result;
  }

  Future<String> getVersion() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String result = await channel.invokeMethod('Crashlytics#getVersion');
    return result;
  }

  /// Add text logging that will be sent with your next report. `msg` will be
  /// printed to the console when in debug mode.
  void log(String msg) {
    _logSize += Uint8List.fromList(msg.codeUnits).length;
    logs.add(msg);
    // Remove oldest log till logSize is no more than 64K.
    while (_logSize > 65536) {
      final String first = logs.removeFirst();
      _logSize -= Uint8List.fromList(first.codeUnits).length;
    }
  }

  void setKey(String key, dynamic value) {
    // Check that only 64 keys are set.
    if (keys.containsKey(key) || keys.length <= 64) {
      keys[key] = value;
    }
  }

  void setBool(String key, bool value) {
    setKey(key, value);
  }

  void setDouble(String key, double value) {
    setKey(key, value);
  }

  void setInt(String key, int value) {
    setKey(key, value);
  }

  void setString(String key, String value) {
    setKey(key, value);
  }

  Future<void> setUserEmail(String email) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
        'Crashlytics#setUserEmail', <String, dynamic>{'email': email});
  }

  Future<void> setUserIdentifier(String identifier) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod('Crashlytics#setUserIdentifier',
        <String, dynamic>{'identifier': identifier});
  }

  Future<void> setUserName(String name) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
        'Crashlytics#setUserName', <String, dynamic>{'name': name});
  }

  @visibleForTesting
  Future<void> sendLogs() async {
    for (int i = 0; i < logs.length; i++) {
      // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await channel.invokeMethod('Crashlytics#log', <String, dynamic>{
        'msg': logs.elementAt(i),
      });
    }
  }

  @visibleForTesting
  Future<void> sendKeys() async {
    for (String key in keys.keys) {
      final dynamic value = keys[key];

      final Map<String, dynamic> crashlyticsKey = <String, dynamic>{
        'key': key,
        'value': value
      };

      if (value is int) {
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await channel.invokeMethod('Crashlytics#setInt', crashlyticsKey);
      } else if (value is double) {
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await channel.invokeMethod('Crashlytics#setDouble', crashlyticsKey);
      } else if (value is String) {
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await channel.invokeMethod('Crashlytics#setString', crashlyticsKey);
      } else if (value is bool) {
        // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await channel.invokeMethod('Crashlytics#setBool', crashlyticsKey);
      }
    }
  }
}
