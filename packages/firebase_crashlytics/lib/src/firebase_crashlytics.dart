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

  Future<void> log(String msg) async {
    await channel.invokeMethod('Crashlytics#log');
  }

  Future<void> setBool(String key, bool value) async {
    await channel.invokeMethod('Crashlytics#setBool', <String, dynamic> {
      key: value
    });
  }

  Future<void> setDouble(String key, double value) async {
    await channel.invokeMethod('Crashlytics#setDouble', <String, dynamic> {
      key: value
    });
  }

  Future<void> setInt(String key, int value) async {
    await channel.invokeMethod('Crashlytics#setInt', <String, dynamic> {
      key: value
    });
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

}

