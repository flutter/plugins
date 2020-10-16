// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

final MethodCodec _codec = const JSONMethodCodec();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PlatformMessageCallback oldHandler;
  MethodCall lastCall;

  setUp(() {
    oldHandler = window.onPlatformMessage;
    window.onPlatformMessage = (String name, ByteData data, PlatformMessageResponseCallback callback) {
      lastCall = _codec.decodeMethodCall(data);
      callback(_codec.encodeSuccessEnvelope(true));
    };
  });

  tearDown(() {
    window.onPlatformMessage = oldHandler;
  });

  test('pushRouteNameToFramework() calls pushRoute when no Router', () async {
    final CustomBuildContext context = CustomBuildContext(router: null);
    await pushRouteNameToFramework(context, '/foo/bar');
    expect(lastCall, isMethodCall(
      'pushRoute',
      arguments: '/foo/bar',
    ));
  });

  test('pushRouteNameToFramework() calls pushRouteInformation when Router exists', () async {
    final CustomBuildContext context = CustomBuildContext(router: CustomRouter());
    await pushRouteNameToFramework(context, '/foo/bar');
    expect(lastCall, isMethodCall(
      'pushRouteInformation',
      arguments: <dynamic, dynamic>{
          'location': '/foo/bar',
          'state': null,
        },
    ));
  });
}

class CustomBuildContext<T> extends Mock implements BuildContext {
  CustomBuildContext({@required this.router});

  final Router<T> router;

  @override
  S findAncestorWidgetOfExactType<S extends Widget>() {
    expect(S, Router);
    return router as S;
  }
}

class CustomRouter extends Mock implements Router {
  @override
  String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) => '';
}
