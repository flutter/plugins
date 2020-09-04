// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'dart:html' as html;
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:mockito/mockito.dart';

import 'package:platform_detect/test_utils.dart' as platform;

class MockWindow extends Mock implements html.Window {}

void main() {
  group('$UrlLauncherPlugin', () {
    MockWindow mockWindow = MockWindow();
    UrlLauncherPlugin plugin = UrlLauncherPlugin(window: mockWindow);

    setUp(() {
      platform.configurePlatformForTesting(browser: platform.chrome);
    });

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

      test('"tel" URLs -> true', () {
        expect(plugin.canLaunch('tel:5551234567'), completion(isTrue));
      });

      test('"sms" URLs -> true', () {
        expect(plugin.canLaunch('sms:+19725551212?body=hello%20there'),
            completion(isTrue));
      });
    });

    group('launch', () {
      setUp(() {
        // Simulate that window.open does something.
        when(mockWindow.open('https://www.google.com', ''))
            .thenReturn(MockWindow());
        when(mockWindow.open('mailto:name@mydomain.com', ''))
            .thenReturn(MockWindow());
        when(mockWindow.open('tel:5551234567', '')).thenReturn(MockWindow());
        when(mockWindow.open('sms:+19725551212?body=hello%20there', ''))
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

      test('launching a "tel" returns true', () {
        expect(
            plugin.launch(
              'tel:5551234567',
              useSafariVC: null,
              useWebView: null,
              universalLinksOnly: null,
              enableDomStorage: null,
              enableJavaScript: null,
              headers: null,
            ),
            completion(isTrue));
      });

      test('launching a "sms" returns true', () {
        expect(
            plugin.launch(
              'sms:+19725551212?body=hello%20there',
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
      test('http urls should be launched in a new window', () {
        plugin.openNewWindow('http://www.google.com');

        verify(mockWindow.open('http://www.google.com', ''));
      });

      test('https urls should be launched in a new window', () {
        plugin.openNewWindow('https://www.google.com');

        verify(mockWindow.open('https://www.google.com', ''));
      });

      test('mailto urls should be launched on a new window', () {
        plugin.openNewWindow('mailto:name@mydomain.com');

        verify(mockWindow.open('mailto:name@mydomain.com', ''));
      });

      test('tel urls should be launched on a new window', () {
        plugin.openNewWindow('tel:5551234567');

        verify(mockWindow.open('tel:5551234567', ''));
      });

      test('sms urls should be launched on a new window', () {
        plugin.openNewWindow('sms:+19725551212?body=hello%20there');

        verify(mockWindow.open('sms:+19725551212?body=hello%20there', ''));
      });
      test('setting oOnlyLinkTarget as _self opens the url in the same tab',
          () {
        plugin.openNewWindow("https://www.google.com",
            webOnlyWindowName: "_self");
        verify(mockWindow.open('https://www.google.com', '_self'));
      });

      test('setting webOnlyLinkTarget as _blank opens the url in a new tab',
          () {
        plugin.openNewWindow("https://www.google.com",
            webOnlyWindowName: "_blank");
        verify(mockWindow.open('https://www.google.com', '_blank'));
      });

      group('Safari', () {
        setUp(() {
          platform.configurePlatformForTesting(browser: platform.safari);
        });

        test('http urls should be launched in a new window', () {
          plugin.openNewWindow('http://www.google.com');

          verify(mockWindow.open('http://www.google.com', ''));
        });

        test('https urls should be launched in a new window', () {
          plugin.openNewWindow('https://www.google.com');

          verify(mockWindow.open('https://www.google.com', ''));
        });

        test('mailto urls should be launched on the same window', () {
          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockWindow.open('mailto:name@mydomain.com', '_top'));
        });

        test('tel urls should be launched on the same window', () {
          plugin.openNewWindow('tel:5551234567');

          verify(mockWindow.open('tel:5551234567', '_top'));
        });

        test('sms urls should be launched on the same window', () {
          plugin.openNewWindow('sms:+19725551212?body=hello%20there');

          verify(
              mockWindow.open('sms:+19725551212?body=hello%20there', '_top'));
        });
        test(
            'mailto urls should use _blank if webOnlyWindowName is set as _blank',
            () {
          plugin.openNewWindow("mailto:name@mydomain.com",
              webOnlyWindowName: "_blank");
          verify(mockWindow.open("mailto:name@mydomain.com", "_blank"));
        });
      });
    });
  });
}
