// Copyright 2017 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'mock_url_launcher_platform.dart';

final MethodCodec _codec = const JSONMethodCodec();

void main() {
  late MockUrlLauncher mock;

  PlatformMessageCallback? realOnPlatformMessage;
  setUp(() {
    mock = MockUrlLauncher();
    UrlLauncherPlatform.instance = mock;
    realOnPlatformMessage = window.onPlatformMessage;
  });
  tearDown(() {
    window.onPlatformMessage = realOnPlatformMessage;
  });

  group('$Link', () {
    testWidgets('handles null uri correctly', (WidgetTester tester) async {
      bool isBuilt = false;
      FollowLink? followLink;

      final Link link = Link(
        uri: null,
        builder: (BuildContext context, FollowLink? followLink2) {
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
      FollowLink? followLink;

      await tester.pumpWidget(Link(
        uri: Uri.parse('http://example.com/foobar'),
        target: LinkTarget.blank,
        builder: (BuildContext context, FollowLink? followLink2) {
          followLink = followLink2;
          return Container();
        },
      ));

      mock
        ..setLaunchExpectations(
          url: 'http://example.com/foobar',
          useSafariVC: false,
          useWebView: false,
          universalLinksOnly: false,
          enableJavaScript: false,
          enableDomStorage: false,
          headers: <String, String>{},
          webOnlyWindowName: null,
        )
        ..setResponse(true);
      await followLink!();
      expect(mock.canLaunchCalled, isTrue);
      expect(mock.launchCalled, isTrue);
    });

    testWidgets('calls url_launcher for external URLs with self target',
        (WidgetTester tester) async {
      FollowLink? followLink;

      await tester.pumpWidget(Link(
        uri: Uri.parse('http://example.com/foobar'),
        target: LinkTarget.self,
        builder: (BuildContext context, FollowLink? followLink2) {
          followLink = followLink2;
          return Container();
        },
      ));

      mock
        ..setLaunchExpectations(
          url: 'http://example.com/foobar',
          useSafariVC: true,
          useWebView: true,
          universalLinksOnly: false,
          enableJavaScript: false,
          enableDomStorage: false,
          headers: <String, String>{},
          webOnlyWindowName: null,
        )
        ..setResponse(true);
      await followLink!();
      expect(mock.canLaunchCalled, isTrue);
      expect(mock.launchCalled, isTrue);
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
        ByteData? data,
        PlatformMessageResponseCallback? callback,
      ) {
        frameworkCalls.add(_codec.decodeMethodCall(data));
        realOnPlatformMessage!(name, data, callback);
      };

      final Uri uri = Uri.parse('/foo/bar');
      FollowLink? followLink;

      await tester.pumpWidget(MaterialApp(
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => Link(
                uri: uri,
                builder: (BuildContext context, FollowLink? followLink2) {
                  followLink = followLink2;
                  return Container();
                },
              ),
          '/foo/bar': (BuildContext context) => Container(),
        },
      ));

      engineCalls.clear();
      frameworkCalls.clear();
      await followLink!();

      // Shouldn't use url_launcher when uri is an internal route name.
      expect(mock.canLaunchCalled, isFalse);
      expect(mock.launchCalled, isFalse);

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
        ByteData? data,
        PlatformMessageResponseCallback? callback,
      ) {
        frameworkCalls.add(_codec.decodeMethodCall(data));
        realOnPlatformMessage!(name, data, callback);
      };

      final Uri uri = Uri.parse('/foo/bar');
      FollowLink? followLink;

      final Link link = Link(
        uri: uri,
        builder: (BuildContext context, FollowLink? followLink2) {
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
      await followLink!();

      // Shouldn't use url_launcher when uri is an internal route name.
      expect(mock.canLaunchCalled, isFalse);
      expect(mock.launchCalled, isFalse);

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

class MockRouteInformationParser extends Mock
    implements RouteInformationParser<bool> {
  @override
  Future<bool> parseRouteInformation(RouteInformation routeInformation) {
    return Future<bool>.value(true);
  }
}

class MockRouterDelegate extends Mock implements RouterDelegate<Object> {
  MockRouterDelegate({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }

  @override
  Future<void> setInitialRoutePath(Object configuration) async {}

  @override
  Future<void> setNewRoutePath(Object configuration) async {}
}
