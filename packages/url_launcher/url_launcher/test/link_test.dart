// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(egarciad): Remove once Mockito has been migrated to null safety.
// @dart = 2.9

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

final MethodCodec _codec = const JSONMethodCodec();

void main() {
  final MockUrlLauncher mock = MockUrlLauncher();
  UrlLauncherPlatform.instance = mock;

  PlatformMessageCallback realOnPlatformMessage;
  setUp(() {
    realOnPlatformMessage = window.onPlatformMessage;
  });
  tearDown(() {
    window.onPlatformMessage = realOnPlatformMessage;
  });

  group('$Link', () {
    testWidgets('handles null uri correctly', (WidgetTester tester) async {
      bool isBuilt = false;
      FollowLink followLink;

      final Link link = Link(
        uri: null,
        builder: (BuildContext context, FollowLink followLink2) {
          isBuilt = true;
          followLink = followLink2;
          return Container();
        },
      );
      await tester.pumpWidget(link);

      expect(link.isDisabled, isTrue);
      expect(isBuilt, isTrue);
      expect(followLink, isNull);
    });

    testWidgets('calls url_launcher for external URLs with blank target',
        (WidgetTester tester) async {
      FollowLink followLink;

      await tester.pumpWidget(Link(
        uri: Uri.parse('http://example.com/foobar'),
        target: LinkTarget.blank,
        builder: (BuildContext context, FollowLink followLink2) {
          followLink = followLink2;
          return Container();
        },
      ));

      when(mock.canLaunch('http://example.com/foobar'))
          .thenAnswer((realInvocation) => Future<bool>.value(true));
      clearInteractions(mock);
      await followLink();

      verifyInOrder([
        mock.canLaunch('http://example.com/foobar'),
        mock.launch(
          'http://example.com/foobar',
          useSafariVC: false,
          useWebView: false,
          universalLinksOnly: false,
          enableJavaScript: false,
          enableDomStorage: false,
          headers: <String, String>{},
        )
      ]);
    });

    testWidgets('calls url_launcher for external URLs with self target',
        (WidgetTester tester) async {
      FollowLink followLink;

      await tester.pumpWidget(Link(
        uri: Uri.parse('http://example.com/foobar'),
        target: LinkTarget.self,
        builder: (BuildContext context, FollowLink followLink2) {
          followLink = followLink2;
          return Container();
        },
      ));

      when(mock.canLaunch('http://example.com/foobar'))
          .thenAnswer((realInvocation) => Future<bool>.value(true));
      clearInteractions(mock);
      await followLink();

      verifyInOrder([
        mock.canLaunch('http://example.com/foobar'),
        mock.launch(
          'http://example.com/foobar',
          useSafariVC: true,
          useWebView: true,
          universalLinksOnly: false,
          enableJavaScript: false,
          enableDomStorage: false,
          headers: <String, String>{},
        )
      ]);
    });

    testWidgets('sends navigation platform messages for internal route names',
        (WidgetTester tester) async {
      // Intercept messages sent to the engine.
      final List<MethodCall> engineCalls = <MethodCall>[];
      SystemChannels.navigation.setMockMethodCallHandler((MethodCall call) {
        engineCalls.add(call);
        return Future<void>.value();
      });

      // Intercept messages sent to the framework.
      final List<MethodCall> frameworkCalls = <MethodCall>[];
      window.onPlatformMessage = (
        String name,
        ByteData data,
        PlatformMessageResponseCallback callback,
      ) {
        frameworkCalls.add(_codec.decodeMethodCall(data));
        realOnPlatformMessage(name, data, callback);
      };

      final Uri uri = Uri.parse('/foo/bar');
      FollowLink followLink;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => Link(
                uri: uri,
                builder: (BuildContext context, FollowLink followLink2) {
                  followLink = followLink2;
                  return Container();
                },
              ),
          '/foo/bar': (BuildContext context) => Container(),
        },
      ));

      engineCalls.clear();
      frameworkCalls.clear();
      clearInteractions(mock);
      await followLink();

      // Shouldn't use url_launcher when uri is an internal route name.
      verifyZeroInteractions(mock);

      // A message should've been sent to the engine (by the Navigator, not by
      // the Link widget).
      //
      // Even though this message isn't being sent by Link, we still want to
      // have a test for it because we rely on it for Link to work correctly.
      expect(engineCalls, hasLength(1));
      expect(
        engineCalls.single,
        isMethodCall('routeUpdated', arguments: <dynamic, dynamic>{
          'previousRouteName': '/',
          'routeName': '/foo/bar',
        }),
      );

      // Pushes route to the framework.
      expect(frameworkCalls, hasLength(1));
      expect(
        frameworkCalls.single,
        isMethodCall('pushRoute', arguments: '/foo/bar'),
      );
    });

    testWidgets('sends router platform messages for internal route names',
        (WidgetTester tester) async {
      // Intercept messages sent to the engine.
      final List<MethodCall> engineCalls = <MethodCall>[];
      SystemChannels.navigation.setMockMethodCallHandler((MethodCall call) {
        engineCalls.add(call);
        return Future<void>.value();
      });

      // Intercept messages sent to the framework.
      final List<MethodCall> frameworkCalls = <MethodCall>[];
      window.onPlatformMessage = (
        String name,
        ByteData data,
        PlatformMessageResponseCallback callback,
      ) {
        frameworkCalls.add(_codec.decodeMethodCall(data));
        realOnPlatformMessage(name, data, callback);
      };

      final Uri uri = Uri.parse('/foo/bar');
      FollowLink followLink;

      final Link link = Link(
        uri: uri,
        builder: (BuildContext context, FollowLink followLink2) {
          followLink = followLink2;
          return Container();
        },
      );
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: MockRouteInformationParser(),
        routerDelegate: MockRouterDelegate(
          builder: (BuildContext context) => link,
        ),
      ));

      engineCalls.clear();
      frameworkCalls.clear();
      clearInteractions(mock);
      await followLink();

      // Shouldn't use url_launcher when uri is an internal route name.
      verifyZeroInteractions(mock);

      // Sends route information update to the engine.
      expect(engineCalls, hasLength(1));
      expect(
        engineCalls.single,
        isMethodCall('routeInformationUpdated', arguments: <dynamic, dynamic>{
          'location': '/foo/bar',
          'state': null
        }),
      );

      // Also pushes route information update to the Router.
      expect(frameworkCalls, hasLength(1));
      expect(
        frameworkCalls.single,
        isMethodCall(
          'pushRouteInformation',
          arguments: <dynamic, dynamic>{
            'location': '/foo/bar',
            'state': null,
          },
        ),
      );
    });
  });
}

class MockUrlLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform {}

class MockRouteInformationParser extends Mock
    implements RouteInformationParser<bool> {
  @override
  Future<bool> parseRouteInformation(RouteInformation routeInformation) {
    return Future<bool>.value(true);
  }
}

class MockRouterDelegate extends Mock implements RouterDelegate {
  MockRouterDelegate({@required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
