// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:url_launcher_platform_interface/link.dart';

final MethodCodec _codec = const JSONMethodCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PlatformMessageCallback? oldHandler;
  MethodCall? lastCall;

  setUp(() {
    oldHandler = window.onPlatformMessage;
    window.onPlatformMessage = (
      String name,
      ByteData? data,
      PlatformMessageResponseCallback? callback,
    ) {
      lastCall = _codec.decodeMethodCall(data);
      if (callback != null) {
        callback(_codec.encodeSuccessEnvelope(true));
      }
    };
  });

  tearDown(() {
    window.onPlatformMessage = oldHandler;
  });

  test('pushRouteNameToFramework() calls pushRoute when no Router', () async {
    await pushRouteNameToFramework(CustomBuildContext(), '/foo/bar');
    expect(
      lastCall,
      isMethodCall(
        'pushRoute',
        arguments: '/foo/bar',
      ),
    );
  });

  test(
    'pushRouteNameToFramework() calls pushRouteInformation when Router exists',
    () async {
      await pushRouteNameToFramework(
        CustomBuildContext(),
        '/foo/bar',
        debugForceRouter: true,
      );
      expect(
        lastCall,
        isMethodCall(
          'pushRouteInformation',
          arguments: <dynamic, dynamic>{
            'location': '/foo/bar',
            'state': null,
          },
        ),
      );
    },
  );
}

class CustomBuildContext<T> extends Mock implements BuildContext {}
