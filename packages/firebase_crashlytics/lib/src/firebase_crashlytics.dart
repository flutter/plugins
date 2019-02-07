// Copyright 2019, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of firebase_crashlytics;

/// The entry point for accessing Crashlytics.
///
/// You can get an instance by calling `Crashlytics.instance`.
class Crashlytics {

  static final Crashlytics instance = Crashlytics();

  /// Set to true to have Errors sent to Crashlytics while in debug mode.
  bool reportInDevMode = false;

  /// Keys to be included with report.
  final Map<String, dynamic> _keys = <String, dynamic>{};

  /// Logs to be included with report.
  final ListQueue<String> _logs = ListQueue<String>(15);
  int logSize = 0;

  bool get isInDebugMode {
    bool _inDebugMode = false;
    assert(_inDebugMode = true);
    return _inDebugMode;
  }

  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_crashlytics');

  Future<void> onError(FlutterErrorDetails details) async {
    print('Error caught by Crashlytics plugin:');
    if (isInDebugMode && !reportInDevMode) {
      print(Trace.format(details.stack).trimRight().split('\n'));
    } else {
      // Send logs
      await _sendLogs();

      // Send keys
      await _sendKeys();

      // Report error
      final List<String> stackTraceLines = Trace.format(details.stack)
          .trimRight().split('\n');
      final dynamic result = await channel.invokeMethod('Crashlytics#onError',
          <String, dynamic>{
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

  Future<bool> isDebuggable() async {
    final bool result = await channel.invokeMethod('Crashlytics#isDebuggable');
    return result;
  }

  Future<String> getVersion() async {
    final String result = await channel.invokeMethod('Crashlytics#getVersion');
    return result;
  }

  void log(String msg) {
    logSize += Uint8List.fromList(msg.codeUnits).length;
    _logs.add(msg);
    // Remove oldest log till logSize is no more than 64K.
    while (logSize > 65536) {
      final String first = _logs.removeFirst();
      logSize -= Uint8List.fromList(first.codeUnits).length;
    }
  }

  void setKey(String key, dynamic value) {
    // Check that only 64 keys are set.
    if (_keys.containsKey(key) || _keys.length <= 64) {
      _keys[key] = value;
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
    await channel.invokeMethod('Crashlytics#setUserEmail', <String, dynamic> {
      'email': email
    });
  }

  Future<void> setUserIdentifier(String identifier) async {
    await channel.invokeMethod('Crashlytics#setUserIdentifier', <String, dynamic> {
      'identifier': identifier
    });
  }

  Future<void> setUserName(String name) async {
    await channel.invokeMethod('Crashlytics#setUserName', <String, dynamic> {
      'name': name
    });
  }

  Future<void> _sendLogs() async {
    for (int i = 0; i < _logs.length; i++) {
      await channel.invokeMethod('Crashlytics#log', <String, dynamic> {
        'msg': _logs.elementAt(i),
      });
    }
  }

  Future<void> _sendKeys() async {
    for (String key in _keys.keys) {
      final dynamic value = _keys[key];

      final Map<String, dynamic> crashlyticsKey = <String, dynamic> {
        'key': key,
        'value': value
      };

      if (value is int) {
        await channel.invokeMethod('Crashlytics#setInt', crashlyticsKey);
      } else if (value is double) {
        await channel.invokeMethod('Crashlytics#setDouble', crashlyticsKey);
      } else if (value is String) {
        await channel.invokeMethod('Crashlytics#setString', crashlyticsKey);
      } else if (value is bool) {
        await channel.invokeMethod('Crashlytics#setBool', crashlyticsKey);
      }
    }
  }

}

