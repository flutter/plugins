// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:flutter/services.dart' show PlatformException;

void main() {
  final MockUrlLauncher mock = MockUrlLauncher();
  when(mock.isMock).thenReturn(true);

  UrlLauncherPlatform.instance = mock;

  test('canLaunch', () async {
    await canLaunch('http://example.com/');
    expect(verify(mock.canLaunch(captureAny)).captured.single,
        'http://example.com/');
  });

  test('launch default behavior', () async {
    await launch('http://example.com/');
    expect(
      verify(mock.launch(
        captureAny,
        useSafariVC: captureAnyNamed('useSafariVC'),
        useWebView: captureAnyNamed('useWebView'),
        enableJavaScript: captureAnyNamed('enableJavaScript'),
        enableDomStorage: captureAnyNamed('enableDomStorage'),
        universalLinksOnly: captureAnyNamed('universalLinksOnly'),
        headers: captureAnyNamed('headers'),
      )).captured,
      <dynamic>[
        'http://example.com/',
        true,
        false,
        false,
        false,
        false,
        <String, String>{},
      ],
    );
  });

  test('launch with headers', () async {
    await launch(
      'http://example.com/',
      headers: <String, String>{'key': 'value'},
    );
    expect(
      verify(mock.launch(
        any,
        useSafariVC: anyNamed('useSafariVC'),
        useWebView: anyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: captureAnyNamed('headers'),
      )).captured.single,
      <String, String>{'key': 'value'},
    );
  });

  test('launch force SafariVC', () async {
    await launch('http://example.com/', forceSafariVC: true);
    expect(
      verify(mock.launch(
        any,
        useSafariVC: captureAnyNamed('useSafariVC'),
        useWebView: anyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured.single,
      true,
    );
  });

  test('launch universal links only', () async {
    await launch('http://example.com/',
        forceSafariVC: false, universalLinksOnly: true);
    expect(
      verify(mock.launch(
        any,
        useSafariVC: captureAnyNamed('useSafariVC'),
        useWebView: anyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: captureAnyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured,
      <bool>[false, true],
    );
  });

  test('launch force WebView', () async {
    await launch('http://example.com/', forceWebView: true);
    expect(
      verify(mock.launch(
        any,
        useSafariVC: anyNamed('useSafariVC'),
        useWebView: captureAnyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured.single,
      true,
    );
  });

  test('launch force WebView enable javascript', () async {
    await launch('http://example.com/',
        forceWebView: true, enableJavaScript: true);
    expect(
      verify(mock.launch(
        any,
        useSafariVC: anyNamed('useSafariVC'),
        useWebView: captureAnyNamed('useWebView'),
        enableJavaScript: captureAnyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured,
      <bool>[true, true],
    );
  });

  test('launch force WebView enable DOM storage', () async {
    await launch('http://example.com/',
        forceWebView: true, enableDomStorage: true);
    expect(
      verify(mock.launch(
        any,
        useSafariVC: anyNamed('useSafariVC'),
        useWebView: captureAnyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: captureAnyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured,
      <bool>[true, true],
    );
  });

  test('launch force SafariVC to false', () async {
    await launch('http://example.com/', forceSafariVC: false);
    expect(
      // ignore: missing_required_param
      verify(mock.launch(
        any,
        useSafariVC: captureAnyNamed('useSafariVC'),
        useWebView: anyNamed('useWebView'),
        enableJavaScript: anyNamed('enableJavaScript'),
        enableDomStorage: anyNamed('enableDomStorage'),
        universalLinksOnly: anyNamed('universalLinksOnly'),
        headers: anyNamed('headers'),
      )).captured.single,
      false,
    );
  });

  test('cannot launch a non-web in webview', () async {
    expect(() async => await launch('tel:555-555-5555', forceWebView: true),
        throwsA(isA<PlatformException>()));
  });

  test('closeWebView default behavior', () async {
    await closeWebView();
    verify(mock.closeWebView());
  });
}

class MockUrlLauncher extends Mock implements UrlLauncherPlatform {}
