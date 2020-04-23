// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'dart:html' as html;
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:url_launcher_web/src/navigator.dart' as navigator;
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  group('URL Launcher for Web', () {
    setUp(() {
      UrlLauncherPlatform.instance = UrlLauncherPlugin();
    });

    test('$UrlLauncherPlugin is the live instance', () {
      expect(UrlLauncherPlatform.instance, isA<UrlLauncherPlugin>());
    });

    test('can launch "http" URLs', () {
      expect(canLaunch('http://google.com'), completion(isTrue));
    });

    test('can launch "https" URLs', () {
      expect(canLaunch('https://google.com'), completion(isTrue));
    });

    test('can launch "mailto" URLs', () {
      expect(canLaunch('mailto:name@mydomain.com'), completion(isTrue));
    });

    test('cannot launch "tel" URLs', () {
      expect(canLaunch('tel:5551234567'), completion(isFalse));
    });

    test('launching a URL returns true', () {
      expect(launch('https://www.google.com'), completion(isTrue));
    });

    test('launching a "mailto" returns true', () {
      expect(launch('mailto:name@mydomain.com'), completion(isTrue));
    });

    test('the window that is launched is a new window', () {
      final UrlLauncherPlugin urlLauncherPlugin = UrlLauncherPlugin();
      final html.WindowBase newWindow =
          urlLauncherPlugin.openNewWindow('https://www.google.com');
      expect(newWindow, isNotNull);
      expect(newWindow, isNot(equals(html.window)));
      expect(newWindow.opener, equals(html.window));
    });

    test('the window that is launched is in the same window', () {
      final originalStandalone = navigator.standalone;
      // Simulate the navigator is in standalone mode on iOS devices.
      // https://developer.mozilla.org/en-US/docs/Web/API/Navigator
      navigator.standalone = true;
      final UrlLauncherPlugin urlLauncherPlugin = UrlLauncherPlugin();
      final html.WindowBase window =
          urlLauncherPlugin.openNewWindow('https://www.google.com');
      expect(window, isNotNull);
      expect(window.opener, isNot(equals(html.window)));
      navigator.standalone = originalStandalone;
    });

    test('does not implement closeWebView()', () {
      expect(closeWebView(), throwsUnimplementedError);
    });
  });
}
