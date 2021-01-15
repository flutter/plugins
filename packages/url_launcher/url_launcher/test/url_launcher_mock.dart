// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';


// class MockMethodChannel extends Mock implements MethodChannel {
//   @override
//   Future<T?> invokeMethod<T>(String method, [dynamic arguments]) async {
//     return super.noSuchMethod(Invocation.method(#invokeMethod, [method, arguments])) as dynamic;
//   }
// }


class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {

  @override
  Future<void> closeWebView() async {
    super.noSuchMethod(Invocation.method(#closeWebView, []));
  }

  @override
  Future<bool> canLaunch(String url) {
    return super.noSuchMethod(Invocation.method(#canLaunch, [url]), Future.value(false)) as dynamic;
  }

  @override
  Future<bool> launch(
    String? url, {
    required bool? useSafariVC,
    required bool? useWebView,
    required bool? enableJavaScript,
    required bool? enableDomStorage,
    required bool? universalLinksOnly,
    required Map<String, String>? headers,
    String? webOnlyWindowName,
  }) async {
    final dynamic result = super
      .noSuchMethod(Invocation.method(
        #launch,
        [url],
        <Symbol, Object?>{
          #useSafariVC : useSafariVC,
          #useWebView : useWebView,
          #enableJavaScript : enableJavaScript,
          #enableDomStorage : enableDomStorage,
          #universalLinksOnly: universalLinksOnly,
          #headers: headers,
          #webOnlyWindowName: webOnlyWindowName,
        }
      ),
      Future.value(false),
    ) as dynamic;

    if (result == null) {
      return false;
    }
    return result;
  }
}
