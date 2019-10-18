// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UrlLauncher with mock platform', () {
    final MockUrlLauncherPlatform platform = MockUrlLauncherPlatform();
    urlLauncherPlatform = platform;

    test('can mock "canLaunch"', () async {
      expect(canLaunch('http://www.google.com'), completion(isFalse));

      platform.launchableUrls.add('http://www.google.com');

      expect(canLaunch('http://www.google.com'), completion(isTrue));

      platform.launchableUrls.clear();
    });

    test('can mock "launch"', () async {
      expect(launch('http://www.google.com'), completion(isFalse));

      platform.launchableUrls.add('http://www.google.com');

      expect(launch('http://www.google.com'), completion(isTrue));

      platform.launchableUrls.clear();
    });

    test('can mock "closeWebView"', () async {
      expect(closeWebView(), completes);
    });
  });
}

class MockUrlLauncherPlatform extends UrlLauncherPlatform {
  Set<String> launchableUrls = Set<String>();

  @override
  Future<bool> canLaunch(String url) {
    return Future.value(launchableUrls.contains(url));
  }

  @override
  Future<void> closeWebView() {
    return Future<void>.value();
  }

  @override
  Future<bool> launch(
    String url,
    bool useSafariVC,
    bool useWebView,
    bool enableJavaScript,
    bool enableDomStorage,
    bool universalLinksOnly,
    Map<String, String> headers,
  ) {
    return Future.value(launchableUrls.contains(url));
  }
}
