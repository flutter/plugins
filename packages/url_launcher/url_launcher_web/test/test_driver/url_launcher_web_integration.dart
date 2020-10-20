// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9
import 'dart:html' as html;
import 'dart:js_util';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_web/url_launcher_web.dart';
import 'package:url_launcher_web/src/link.dart';
import 'package:mockito/mockito.dart';
import 'package:integration_test/integration_test.dart';

class _MockWindow extends Mock implements html.Window {}

class _MockNavigator extends Mock implements html.Navigator {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('UrlLauncherPlugin', () {
    late _MockWindow mockWindow;
    late _MockNavigator mockNavigator;

    late UrlLauncherPlugin plugin;

    setUp(() {
      mockWindow = _MockWindow();
      mockNavigator = _MockNavigator();
      when(mockWindow.navigator).thenReturn(mockNavigator);

      plugin = UrlLauncherPlugin(debugWindow: mockWindow);
    });

    group('canLaunch', () {
      testWidgets('"http" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('http://google.com'), completion(isTrue));
      });

      testWidgets('"https" URLs -> true', (WidgetTester _) async {
        expect(
            plugin.canLaunch('https://go, (Widogle.com'), completion(isTrue));
      });

      testWidgets('"mailto" URLs -> true', (WidgetTester _) async {
        expect(
            plugin.canLaunch('mailto:name@mydomain.com'), completion(isTrue));
      });

      testWidgets('"tel" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('tel:5551234567'), completion(isTrue));
      });

      testWidgets('"sms" URLs -> true', (WidgetTester _) async {
        expect(plugin.canLaunch('sms:+19725551212?body=hello%20there'),
            completion(isTrue));
      });
    });

    group('launch', () {
      setUp(() {
        // Simulate that window.open does something.
        when(mockWindow.open('https://www.google.com', ''))
            .thenReturn(_MockWindow());
        when(mockWindow.open('mailto:name@mydomain.com', ''))
            .thenReturn(_MockWindow());
        when(mockWindow.open('tel:5551234567', '')).thenReturn(_MockWindow());
        when(mockWindow.open('sms:+19725551212?body=hello%20there', ''))
            .thenReturn(_MockWindow());
      });

      testWidgets('launching a URL returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'https://www.google.com',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "mailto" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'mailto:name@mydomain.com',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "tel" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'tel:5551234567',
            ),
            completion(isTrue));
      });

      testWidgets('launching a "sms" returns true', (WidgetTester _) async {
        expect(
            plugin.launch(
              'sms:+19725551212?body=hello%20there',
            ),
            completion(isTrue));
      });
    });

    group('openNewWindow', () {
      testWidgets('http urls should be launched in a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('http://www.google.com');

        verify(mockWindow.open('http://www.google.com', ''));
      });

      testWidgets('https urls should be launched in a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com');

        verify(mockWindow.open('https://www.google.com', ''));
      });

      testWidgets('mailto urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('mailto:name@mydomain.com');

        verify(mockWindow.open('mailto:name@mydomain.com', ''));
      });

      testWidgets('tel urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('tel:5551234567');

        verify(mockWindow.open('tel:5551234567', ''));
      });

      testWidgets('sms urls should be launched on a new window',
          (WidgetTester _) async {
        plugin.openNewWindow('sms:+19725551212?body=hello%20there');

        verify(mockWindow.open('sms:+19725551212?body=hello%20there', ''));
      });
      testWidgets(
          'setting webOnlyLinkTarget as _self opens the url in the same tab',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com',
            webOnlyWindowName: '_self');
        verify(mockWindow.open('https://www.google.com', '_self'));
      });

      testWidgets(
          'setting webOnlyLinkTarget as _blank opens the url in a new tab',
          (WidgetTester _) async {
        plugin.openNewWindow('https://www.google.com',
            webOnlyWindowName: '_blank');
        verify(mockWindow.open('https://www.google.com', '_blank'));
      });

      group('Safari', () {
        setUp(() {
          when(mockNavigator.vendor).thenReturn('Apple Computer, Inc.');
          when(mockNavigator.appVersion).thenReturn(
              '5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Safari/605.1.15');
          // Recreate the plugin, so it grabs the overrides from this group
          plugin = UrlLauncherPlugin(debugWindow: mockWindow);
        });

        testWidgets('http urls should be launched in a new window',
            (WidgetTester _) async {
          plugin.openNewWindow('http://www.google.com');

          verify(mockWindow.open('http://www.google.com', ''));
        });

        testWidgets('https urls should be launched in a new window',
            (WidgetTester _) async {
          plugin.openNewWindow('https://www.google.com');

          verify(mockWindow.open('https://www.google.com', ''));
        });

        testWidgets('mailto urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('mailto:name@mydomain.com');

          verify(mockWindow.open('mailto:name@mydomain.com', '_top'));
        });

        testWidgets('tel urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('tel:5551234567');

          verify(mockWindow.open('tel:5551234567', '_top'));
        });

        testWidgets('sms urls should be launched on the same window',
            (WidgetTester _) async {
          plugin.openNewWindow('sms:+19725551212?body=hello%20there');

          verify(
              mockWindow.open('sms:+19725551212?body=hello%20there', '_top'));
        });
        testWidgets(
            'mailto urls should use _blank if webOnlyWindowName is set as _blank',
            (WidgetTester _) async {
          plugin.openNewWindow('mailto:name@mydomain.com',
              webOnlyWindowName: '_blank');
          verify(mockWindow.open('mailto:name@mydomain.com', '_blank'));
        });
      });
    });
  });

  group('link', () {
    testWidgets('creates anchor with correct attributes',
        (WidgetTester tester) async {
      final Uri uri = Uri.parse('http://foobar/example?q=1');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: uri,
          target: LinkTarget.blank,
          builder: (BuildContext context, FollowLink followLink) {
            return Container(width: 100, height: 100);
          },
        )),
      ));
      // Platform view creation happens asynchronously.
      await tester.pumpAndSettle();

      final html.Element anchor = _findSingleAnchor();
      expect(anchor.getAttribute('href'), uri.toString());
      expect(anchor.getAttribute('target'), '_blank');

      final Uri uri2 = Uri.parse('http://foobar2/example?q=2');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: WebLinkDelegate(TestLinkInfo(
          uri: uri2,
          target: LinkTarget.self,
          builder: (BuildContext context, FollowLink followLink) {
            return Container(width: 100, height: 100);
          },
        )),
      ));
      await tester.pumpAndSettle();

      // Check that the same anchor has been updated.
      expect(anchor.getAttribute('href'), uri2.toString());
      expect(anchor.getAttribute('target'), '_self');
    });

    testWidgets('sizes itself correctly', (WidgetTester tester) async {
      final Key containerKey = GlobalKey();
      final Uri uri = Uri.parse('http://foobar');
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(Size(100.0, 100.0)),
            child: WebLinkDelegate(TestLinkInfo(
              uri: uri,
              target: LinkTarget.blank,
              builder: (BuildContext context, FollowLink followLink) {
                return Container(
                  key: containerKey,
                  child: SizedBox(width: 50.0, height: 50.0),
                );
              },
            )),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final Size containerSize = tester.getSize(find.byKey(containerKey));
      // The Stack widget inserted by the `WebLinkDelegate` shouldn't loosen the
      // constraints before passing them to the inner container. So the inner
      // container should respect the tight constraints given by the ancestor
      // `ConstrainedBox` widget.
      expect(containerSize.width, 100.0);
      expect(containerSize.height, 100.0);
    });
  });
}

html.Element _findSingleAnchor() {
  final List<html.Element> foundAnchors = <html.Element>[];
  for (final html.Element anchor in html.document.querySelectorAll('a')) {
    if (hasProperty(anchor, linkViewIdProperty)) {
      foundAnchors.add(anchor);
    }
  }

  // Search inside platform views with shadow roots as well.
  for (final html.Element platformView
      in html.document.querySelectorAll('flt-platform-view')) {
    final html.ShadowRoot shadowRoot = platformView.shadowRoot;
    if (shadowRoot != null) {
      for (final html.Element anchor in shadowRoot.querySelectorAll('a')) {
        if (hasProperty(anchor, linkViewIdProperty)) {
          foundAnchors.add(anchor);
        }
      }
    }
  }

  return foundAnchors.single;
}

class TestLinkInfo extends LinkInfo {
  @override
  final LinkWidgetBuilder builder;

  @override
  final Uri uri;

  @override
  final LinkTarget target;

  @override
  bool get isDisabled => uri == null;

  TestLinkInfo({
    @required this.uri,
    @required this.target,
    @required this.builder,
  });
}
