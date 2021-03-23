// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info/package_info.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/package_info');
  late List<MethodCall> log;

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
    switch (methodCall.method) {
      case 'getAll':
        return <String, dynamic>{
          'appName': 'package_info_example',
          'buildNumber': '1',
          'packageName': 'io.flutter.plugins.packageinfoexample',
          'version': '1.0',
        };
      default:
        assert(false);
        return null;
    }
  });

  setUp(() {
    log = <MethodCall>[];
  });

  test('fromPlatform', () async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    expect(info.appName, 'package_info_example');
    expect(info.buildNumber, '1');
    expect(info.packageName, 'io.flutter.plugins.packageinfoexample');
    expect(info.version, '1.0');
    expect(
      log,
      <Matcher>[
        isMethodCall('getAll', arguments: null),
      ],
    );
  });
}
