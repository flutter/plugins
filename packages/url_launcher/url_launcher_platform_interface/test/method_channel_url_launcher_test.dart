// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/method_channel_url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  group('$MethodChannelUrlLauncher', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/url_launcher');
    final List<MethodCall> log = <MethodCall>[];
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    final MethodChannelUrlLauncher launcher = MethodChannelUrlLauncher();

    tearDown(() {
      log.clear();
    });

    test('is the default $UrlLauncherPlatform instance', () {
      expect(UrlLauncherPlatform.instance,
          isInstanceOf<MethodChannelUrlLauncher>());
    });

    test('canLaunch', () async {
      await launcher.canLaunch('http://example.com/');
      expect(
        log,
        <Matcher>[
          isMethodCall('canLaunch', arguments: <String, Object>{
            'url': 'http://example.com/',
          })
        ],
      );
    });

    test('launch', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': false,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch with headers', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{'key': 'value'},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': false,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{'key': 'value'},
          })
        ],
      );
    });

    test('launch force SafariVC', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': false,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch universal links only', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: false,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: true,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': false,
            'useWebView': false,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': true,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch force WebView', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': true,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch force WebView enable javascript', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: true,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': true,
            'enableJavaScript': true,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch force WebView enable DOM storage', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: true,
        useWebView: true,
        enableJavaScript: false,
        enableDomStorage: true,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': true,
            'useWebView': true,
            'enableJavaScript': false,
            'enableDomStorage': true,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('launch force SafariVC to false', () async {
      await launcher.launch(
        'http://example.com/',
        useSafariVC: false,
        useWebView: false,
        enableJavaScript: false,
        enableDomStorage: false,
        universalLinksOnly: false,
        headers: const <String, String>{},
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('launch', arguments: <String, Object>{
            'url': 'http://example.com/',
            'useSafariVC': false,
            'useWebView': false,
            'enableJavaScript': false,
            'enableDomStorage': false,
            'universalLinksOnly': false,
            'headers': <String, String>{},
          })
        ],
      );
    });

    test('closeWebView default behavior', () async {
      await launcher.closeWebView();
      expect(
        log,
        <Matcher>[isMethodCall('closeWebView', arguments: null)],
      );
    });
  });
}
