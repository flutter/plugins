import 'dart:async';
import 'dart:io';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info/package_info.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('package_info test driver', () {
    test('test package info result', () async {
      final PackageInfo info = await PackageInfo.fromPlatform();
      // These tests are based on the example app. The tests should be updated if any related info changes.
      if (Platform.isAndroid) {
        expect(info.appName, 'package_info_example');
        expect(info.buildNumber, '1');
        expect(info.packageName, 'io.flutter.plugins.packageinfoexample');
        expect(info.version, '1.0');
      } else if (Platform.isIOS) {
        expect(info.appName, 'Package Info Example');
        expect(info.buildNumber, '1');
        expect(info.packageName, 'io.flutter.plugins.packageInfoExample');
        expect(info.version, '1.0');
      } else {
        throw (UnsupportedError('platform not supported'));
      }
    });
  });
}
