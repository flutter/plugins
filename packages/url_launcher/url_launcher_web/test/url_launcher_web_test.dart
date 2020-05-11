// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'dart:html' as html;
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:mockito/mockito.dart';

class MockNavigator extends Mock implements html.Navigator {
  final String platform;

  MockNavigator(this.platform);
}

class MockWindow extends Mock implements html.Window {
  final MockNavigator navigator;

  MockWindow({String platform = ''}) : navigator = MockNavigator(platform);
}

void main() {
  group('$UrlLauncherPlugin', () {
    MockWindow mockWindow = MockWindow();
    UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockWindow);

    group('canLaunch', () {
      test('"http" URLs -> true', () {
        expect(plugin.canLaunch('http://google.com'), completion(isTrue));
      });

      test('"https" URLs -> true', () {
        expect(plugin.canLaunch('https://google.com'), completion(isTrue));
      });

      test('"mailto" URLs -> true', () {
        expect(
            plugin.canLaunch('mailto:name@mydomain.com'), completion(isTrue));
      });

      test('"tel" URLs -> false', () {
        expect(plugin.canLaunch('tel:5551234567'), completion(isFalse));
      });
    });

    group('launch', () {
      setUp(() {
        // Simulate that window.open does something.
        when(mockWindow.open('https://www.google.com', ''))
            .thenReturn(MockWindow());
        when(mockWindow.open('mailto:name@mydomain.com', ''))
            .thenReturn(MockWindow());
      });

      test('launching a URL returns true', () {
        expect(
            plugin.launch(
              'https://www.google.com',
              useSafariVC: null,
              useWebView: null,
              universalLinksOnly: null,
              enableDomStorage: null,
              enableJavaScript: null,
              headers: null,
            ),
            completion(isTrue));
      });

      test('launching a "mailto" returns true', () {
        expect(
            plugin.launch(
              'mailto:name@mydomain.com',
              useSafariVC: null,
              useWebView: null,
              universalLinksOnly: null,
              enableDomStorage: null,
              enableJavaScript: null,
              headers: null,
            ),
            completion(isTrue));
      });
    });

    group('openNewWindow', () {
      test('the window that is launched is a new window', () {
        plugin.openNewWindow('https://www.google.com');

        verify(mockWindow.open('https://www.google.com', ''));
      });

      group('iosDevices', () {
        test('http urls should be launched in a new window', () {
          final mockIosWindow = MockWindow(platform: 'iPhone');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('http://www.google.com');

          verify(mockIosWindow.open('http://www.google.com', ''));
        });

        test('https urls should be launched in a new window', () {
          final mockIosWindow = MockWindow(platform: 'iPhone');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('https://www.google.com');

          verify(mockIosWindow.open('https://www.google.com', ''));
        });

        test('mailto urls should be launched on the same window on Iphone', () {
          final mockIosWindow = MockWindow(platform: 'iPhone');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test('mailto urls should be launched on the same window on Ipad', () {
          final mockIosWindow = MockWindow(platform: 'iPad');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test('mailto urls should be launched on the same window on Iphone', () {
          final mockIosWindow = MockWindow(platform: 'iPod');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test(
            'mailto urls should be launched on the same window on an simulated Iphone',
            () {
          final mockIosWindow = MockWindow(platform: 'iPhone Simulator');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test(
            'mailto urls should be launched on the same window on an simulated Ipad',
            () {
          final mockIosWindow = MockWindow(platform: 'iPad Simulator');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test(
            'mailto urls should be launched on the same window on an simulated Iphone',
            () {
          final mockIosWindow = MockWindow(platform: 'iPod Simulator');
          UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockIosWindow);

          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockIosWindow.open('mailto:name@mydomain.com', '_top'));
        });
      });
    });
  });
}
