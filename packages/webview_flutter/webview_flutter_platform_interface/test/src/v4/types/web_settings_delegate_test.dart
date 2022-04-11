// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

import '../webview_platform_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WebSetting', () {
    test('absent should initialize isPresent to false', () {
      const WebSetting<String> absent = WebSetting<String>.absent();
      expect(absent.isPresent, isFalse);
    });

    test('Cannot access value of absent setting', () {
      const WebSetting<String> absent = WebSetting<String>.absent();
      expect(() => absent.value, throwsA(isA<StateError>()));
    });

    test('Setting should return value it is initialized with', () {
      const WebSetting<String> setting = WebSetting<String>.of('Test value');
      expect(setting.isPresent, isTrue);
      expect(setting.value, 'Test value');
    });
  });

  group('WebSettingsDelegate', () {
    setUp(() {
      WebViewPlatform.instance = MockWebViewPlatformWithMixin();
    });

    test('Cannot be implemented with `implements`', () {
      const WebSetting<String> absentSetting = WebSetting<String>.absent();
      when(WebViewPlatform.instance!.createWebSettingsDelegate(
        options: const WebSettingsDelegateCreationParams(
          userAgent: absentSetting,
        ),
      )).thenReturn(ImplementsWebSettingsDelegate());

      expect(() {
        WebSettingsDelegate(
          options: const WebSettingsDelegateCreationParams(
            userAgent: absentSetting,
          ),
        );
      }, throwsNoSuchMethodError);
    });

    test('Can be extended', () {
      const WebSetting<String> absentSetting = WebSetting<String>.absent();
      const WebSettingsDelegateCreationParams options =
          WebSettingsDelegateCreationParams(
        userAgent: absentSetting,
      );
      when(WebViewPlatform.instance!.createWebSettingsDelegate(
        options: options,
      )).thenReturn(ExtendsWebSettingsDelegate(options: options));

      expect(WebSettingsDelegate(options: options), isNotNull);
    });

    test('Can be mocked with `implements`', () {
      const WebSetting<String> absentSetting = WebSetting<String>.absent();
      const WebSettingsDelegateCreationParams options =
          WebSettingsDelegateCreationParams(
        userAgent: absentSetting,
      );
      when(WebViewPlatform.instance!
              .createWebSettingsDelegate(options: options))
          .thenReturn(MockWebSettingsDelegate());

      expect(WebSettingsDelegate(options: options), isNotNull);
    });
  });
}

class MockWebViewPlatformWithMixin extends MockWebViewPlatform
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin {}

class ImplementsWebSettingsDelegate implements WebSettingsDelegate {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWebSettingsDelegate extends Mock
    with
        // ignore: prefer_mixin
        MockPlatformInterfaceMixin
    implements
        WebSettingsDelegate {}

class ExtendsWebSettingsDelegate extends WebSettingsDelegate {
  ExtendsWebSettingsDelegate({
    required WebSettingsDelegateCreationParams options,
  }) : super.implementation(options: options);
}
