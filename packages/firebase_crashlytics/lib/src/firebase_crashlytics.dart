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
  final Map<String, dynamic> _keys = <String, dynamic>{};

  /// Logs to be included with report.
  final ListQueue<String> _logs = ListQueue<String>(15);
  int _logSize = 0;

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_crashlytics');

  /// Submits non-fatal crash report to Firebase Crashlytics.
  Future<void> onError(FlutterErrorDetails details) async {
    print('Error caught by Crashlytics plugin:');

    bool inDebugMode = false;
    if (!enableInDevMode) {
      assert(inDebugMode = true);
    }

    if (inDebugMode && !enableInDevMode) {
      print(Trace.format(details.stack));
    } else {
      // Report error
      final List<String> stackTraceLines =
          Trace.format(details.stack).trimRight().split('\n');
      final List<Map<String, String>> stackTraceElements =
          _getStackTraceElements(stackTraceLines);
      final dynamic result =
          // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
          // https://github.com/flutter/flutter/issues/26431
          // ignore: strong_mode_implicit_dynamic_method
          await channel.invokeMethod('Crashlytics#onError', <String, dynamic>{
        'exception': details.exceptionAsString(),
        // FlutterErrorDetails.context has been migrated from a String to a
        // DiagnosticsNode. Coerce it to a String here in a way that will work
        // on both Strings and the new DiagnosticsNode values. See https://groups.google.com/forum/#!topic/flutter-announce/hp1RNIgej38
        'context': '${details.context}',
        'stackTraceElements': stackTraceElements,
        'logs': _logs.toList(),
        'keys': _prepareKeys(),
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

  /// Returns Crashlytics SDK version.
  Future<String> getVersion() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String result = await channel.invokeMethod('Crashlytics#getVersion');
    return result;
  }

  /// Add text logging that will be sent with your next report. `msg` will be
  /// printed to the console when in debug mode. Each report has a rolling max
  /// of 64k of logs, older logs are removed to allow newer logs to fit within
  /// the limit.
  void log(String msg) {
    _logSize += Uint8List.fromList(msg.codeUnits).length;
    _logs.add(msg);
    // Remove oldest log till logSize is no more than 64K.
    while (_logSize > 65536) {
      final String first = _logs.removeFirst();
      _logSize -= Uint8List.fromList(first.codeUnits).length;
    }
  }

  void _setValue(String key, dynamic value) {
    // Check that only 64 keys are set.
    if (_keys.containsKey(key) || _keys.length <= 64) {
      _keys[key] = value;
    }
  }

  /// Sets a value to be associated with a given key for your crash data.
  void setBool(String key, bool value) {
    _setValue(key, value);
  }

  /// Sets a value to be associated with a given key for your crash data.
  void setDouble(String key, double value) {
    _setValue(key, value);
  }

  /// Sets a value to be associated with a given key for your crash data.
  void setInt(String key, int value) {
    _setValue(key, value);
  }

  /// Sets a value to be associated with a given key for your crash data.
  void setString(String key, String value) {
    _setValue(key, value);
  }

  /// Optionally set a end-user's name or username for display within the
  /// Crashlytics UI. Please be mindful of end-user's privacy.
  Future<void> setUserEmail(String email) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
        'Crashlytics#setUserEmail', <String, dynamic>{'email': email});
  }

  /// Specify a user identifier which will be visible in the Crashlytics UI.
  /// Please be mindful of end-user's privacy.
  Future<void> setUserIdentifier(String identifier) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod('Crashlytics#setUserIdentifier',
        <String, dynamic>{'identifier': identifier});
  }

  /// Specify a user name which will be visible in the Crashlytics UI. Please
  /// be mindful of end-user's privacy.
  Future<void> setUserName(String name) async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await channel.invokeMethod(
        'Crashlytics#setUserName', <String, dynamic>{'name': name});
  }

  List<Map<String, dynamic>> _prepareKeys() {
    final List<Map<String, dynamic>> crashlyticsKeys = <Map<String, dynamic>>[];
    for (String key in _keys.keys) {
      final dynamic value = _keys[key];

      final Map<String, dynamic> crashlyticsKey = <String, dynamic>{
        'key': key,
        'value': value
      };

      if (value is int) {
        crashlyticsKey['type'] = 'int';
      } else if (value is double) {
        crashlyticsKey['type'] = 'double';
      } else if (value is String) {
        crashlyticsKey['type'] = 'string';
      } else if (value is bool) {
        crashlyticsKey['type'] = 'boolean';
      }
    }

    return crashlyticsKeys;
  }

  List<Map<String, String>> _getStackTraceElements(List<String> lines) {
    final List<Map<String, String>> elements = <Map<String, String>>[];
    for (String line in lines) {
      final List<String> lineParts = line.split(RegExp('\\s+'));
      try {
        final String fileName = lineParts[0];
        final String lineNumber =
            lineParts[1].substring(0, lineParts[1].indexOf(":")).trim();
        final String className =
            lineParts[2].substring(0, lineParts[2].indexOf(".")).trim();
        final String methodName =
            lineParts[2].substring(lineParts[2].indexOf(".") + 1).trim();

        elements.add(<String, String>{
          'class': className,
          'method': methodName,
          'file': fileName,
          'line': lineNumber,
        });
      } catch (e) {
        print(e.toString());
      }
    }
    return elements;
  }
}
