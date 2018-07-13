// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/url_launcher');
  final List<MethodCall> log = <MethodCall>[];
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    log.add(methodCall);
  });

  tearDown(() {
    log.clear();
  });

  test('canLaunch', () async {
    await canLaunch('http://example.com/');
    expect(
      log,
      <Matcher>[
        isMethodCall('canLaunch', arguments: <String, Object>{
          'url': 'http://example.com/',
        })
      ],
    );
  });

  test('launch default behavior', () async {
    await launch('http://example.com/');
    expect(
      log,
      <Matcher>[
        isMethodCall('launch', arguments: <String, Object>{
          'url': 'http://example.com/',
          'useSafariVC': true,
          'useWebView': false,
          'enableJavaScript': false,
        })
      ],
    );
  });

  test('launch force SafariVC', () async {
    await launch('http://example.com/', forceSafariVC: true);
    expect(
      log,
      <Matcher>[
        isMethodCall('launch', arguments: <String, Object>{
          'url': 'http://example.com/',
          'useSafariVC': true,
          'useWebView': false,
          'enableJavaScript': false,
        })
      ],
    );
  });

  test('launch force WebView', () async {
    await launch('http://example.com/', forceWebView: true);
    expect(
      log,
      <Matcher>[
        isMethodCall('launch', arguments: <String, Object>{
          'url': 'http://example.com/',
          'useSafariVC': true,
          'useWebView': true,
          'enableJavaScript': false,
        })
      ],
    );
  });

  test('launch force WebView enable javascript', () async {
    await launch('http://example.com/',
        forceWebView: true, enableJavaScript: true);
    expect(
      log,
      <Matcher>[
        isMethodCall('launch', arguments: <String, Object>{
          'url': 'http://example.com/',
          'useSafariVC': true,
          'useWebView': true,
          'enableJavaScript': true,
        })
      ],
    );
  });

  test('launch force SafariVC to false', () async {
    await launch('http://example.com/', forceSafariVC: false);
    expect(
      log,
      <Matcher>[
        isMethodCall('launch', arguments: <String, Object>{
          'url': 'http://example.com/',
          'useSafariVC': false,
          'useWebView': false,
          'enableJavaScript': false,
        })
      ],
    );
  });

  test('cannot launch a non-web in webview', () async {
    expect(() async => await launch('tel:555-555-5555', forceWebView: true),
        throwsA(isInstanceOf<PlatformException>()));
  });

  test('closeWebView default behavior', () async {
    await closeWebView();
    expect(
      log,
      <Matcher>[isMethodCall('closeWebView', arguments: null)],
    );
  });
}
