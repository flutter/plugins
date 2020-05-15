// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:flutter/services.dart' show PlatformException;

void main() {
  final MockUrlLauncher mock = MockUrlLauncher();
  UrlLauncherPlatform.instance = mock;

  test('closeWebView default behavior', () async {
    await closeWebView();
    verify(mock.closeWebView());
  });

  group('canLaunch', () {
    test('returns true', () async {
      when(mock.canLaunch('foo')).thenAnswer((_) => Future<bool>.value(true));

      final bool result = await canLaunch('foo');

      expect(result, isTrue);
    });

    test('returns false', () async {
      when(mock.canLaunch('foo')).thenAnswer((_) => Future<bool>.value(false));

      final bool result = await canLaunch('foo');

      expect(result, isFalse);
    });
  });
  group('launch', () {
    test('requires a non-null urlString', () {
      expect(() => launch(null), throwsAssertionError);
    });

    test('default behavior', () async {
      await launch('http://flutter.dev/');
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
          'http://flutter.dev/',
          true,
          false,
          false,
          false,
          false,
          <String, String>{},
        ],
      );
    });

    test('with headers', () async {
      await launch(
        'http://flutter.dev/',
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

    test('force SafariVC', () async {
      await launch('http://flutter.dev/', forceSafariVC: true);
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

    test('universal links only', () async {
      await launch('http://flutter.dev/',
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

    test('force WebView', () async {
      await launch('http://flutter.dev/', forceWebView: true);
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

    test('force WebView enable javascript', () async {
      await launch('http://flutter.dev/',
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

    test('force WebView enable DOM storage', () async {
      await launch('http://flutter.dev/',
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

    test('force SafariVC to false', () async {
      await launch('http://flutter.dev/', forceSafariVC: false);
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

    test('controls system UI when changing statusBarBrightness', () async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      binding.renderView.automaticSystemUiAdjustment = true;
      final Future<bool> launchResult =
          launch('http://flutter.dev/', statusBarBrightness: Brightness.dark);

      // Should take over control of the automaticSystemUiAdjustment while it's
      // pending, then restore it back to normal after the launch finishes.
      expect(binding.renderView.automaticSystemUiAdjustment, isFalse);
      await launchResult;
      expect(binding.renderView.automaticSystemUiAdjustment, isTrue);
    });

    test('sets automaticSystemUiAdjustment to not be null', () async {
      final TestWidgetsFlutterBinding binding =
          TestWidgetsFlutterBinding.ensureInitialized();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(binding.renderView.automaticSystemUiAdjustment, true);
      final Future<bool> launchResult =
          launch('http://flutter.dev/', statusBarBrightness: Brightness.dark);

      // The automaticSystemUiAdjustment should be set before the launch
      // and equal to true after the launch result is complete.
      expect(binding.renderView.automaticSystemUiAdjustment, true);
      await launchResult;
      expect(binding.renderView.automaticSystemUiAdjustment, true);
    });
  });
}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}
