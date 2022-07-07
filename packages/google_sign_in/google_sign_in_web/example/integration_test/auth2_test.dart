// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:integration_test/integration_test.dart';
import 'package:js/js_util.dart' as js_util;

import 'gapi_mocks/gapi_mocks.dart' as gapi_mocks;
import 'src/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final GoogleSignInTokenData expectedTokenData =
      GoogleSignInTokenData(idToken: '70k3n', accessToken: 'access_70k3n');

  final GoogleSignInUserData expectedUserData = GoogleSignInUserData(
    displayName: 'Foo Bar',
    email: 'foo@example.com',
    id: '123',
    photoUrl: 'http://example.com/img.jpg',
    idToken: expectedTokenData.idToken,
  );

  late GoogleSignInPlugin plugin;

  group('plugin.initWithParams() throws a catchable exception', () {
    setUp(() {
      // The pre-configured use case for the instances of the plugin in this test
      gapiUrl = toBase64Url(gapi_mocks.auth2InitError());
      plugin = GoogleSignInPlugin();
    });

    testWidgets('throws PlatformException', (WidgetTester tester) async {
      await expectLater(
          plugin.initWithParams(const SignInInitParameters(
            hostedDomain: 'foo',
            scopes: <String>['some', 'scope'],
            clientId: '1234',
          )),
          throwsA(isA<PlatformException>()));
    });

    testWidgets('forwards error code from JS', (WidgetTester tester) async {
      try {
        await plugin.initWithParams(const SignInInitParameters(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        ));
        fail('plugin.initWithParams should have thrown an exception!');
      } catch (e) {
        final String code = js_util.getProperty<String>(e, 'code');
        expect(code, 'idpiframe_initialization_failed');
      }
    });
  });

  group('other methods also throw catchable exceptions on initWithParams fail',
      () {
    // This function ensures that initWithParams gets called, but for some
    // reason, we ignored that it has thrown stuff...
    Future<void> _discardInit() async {
      try {
        await plugin.initWithParams(const SignInInitParameters(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        ));
      } catch (e) {
        // Noop so we can call other stuff
      }
    }

    setUp(() {
      gapiUrl = toBase64Url(gapi_mocks.auth2InitError());
      plugin = GoogleSignInPlugin();
    });

    testWidgets('signInSilently throws', (WidgetTester tester) async {
      await _discardInit();
      await expectLater(
          plugin.signInSilently(), throwsA(isA<PlatformException>()));
    });

    testWidgets('signIn throws', (WidgetTester tester) async {
      await _discardInit();
      await expectLater(plugin.signIn(), throwsA(isA<PlatformException>()));
    });

    testWidgets('getTokens throws', (WidgetTester tester) async {
      await _discardInit();
      await expectLater(plugin.getTokens(email: 'test@example.com'),
          throwsA(isA<PlatformException>()));
    });
    testWidgets('requestScopes', (WidgetTester tester) async {
      await _discardInit();
      await expectLater(plugin.requestScopes(<String>['newScope']),
          throwsA(isA<PlatformException>()));
    });
  });

  group('auth2 Init Successful', () {
    setUp(() {
      // The pre-configured use case for the instances of the plugin in this test
      gapiUrl = toBase64Url(gapi_mocks.auth2InitSuccess(expectedUserData));
      plugin = GoogleSignInPlugin();
    });

    testWidgets('Init requires clientId', (WidgetTester tester) async {
      expect(
          plugin.initWithParams(const SignInInitParameters(hostedDomain: '')),
          throwsAssertionError);
    });

    testWidgets("Init doesn't accept serverClientId",
        (WidgetTester tester) async {
      expect(
          plugin.initWithParams(const SignInInitParameters(
            clientId: '',
            serverClientId: '',
          )),
          throwsAssertionError);
    });

    testWidgets("Init doesn't accept spaces in scopes",
        (WidgetTester tester) async {
      expect(
          plugin.initWithParams(const SignInInitParameters(
            hostedDomain: '',
            clientId: '',
            scopes: <String>['scope with spaces'],
          )),
          throwsAssertionError);
    });

    // See: https://github.com/flutter/flutter/issues/88084
    testWidgets('Init passes plugin_name parameter with the expected value',
        (WidgetTester tester) async {
      await plugin.initWithParams(const SignInInitParameters(
        hostedDomain: 'foo',
        scopes: <String>['some', 'scope'],
        clientId: '1234',
      ));

      final Object? initParameters =
          js_util.getProperty(html.window, 'gapi2.init.parameters');
      expect(initParameters, isNotNull);

      final Object? pluginNameParameter =
          js_util.getProperty(initParameters!, 'plugin_name');
      expect(pluginNameParameter, isA<String>());
      expect(pluginNameParameter, 'dart-google_sign_in_web');
    });

    group('Successful .initWithParams, then', () {
      setUp(() async {
        await plugin.initWithParams(const SignInInitParameters(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        ));
        await plugin.initialized;
      });

      testWidgets('signInSilently', (WidgetTester tester) async {
        final GoogleSignInUserData actualUser =
            (await plugin.signInSilently())!;

        expect(actualUser, expectedUserData);
      });

      testWidgets('signIn', (WidgetTester tester) async {
        final GoogleSignInUserData actualUser = (await plugin.signIn())!;

        expect(actualUser, expectedUserData);
      });

      testWidgets('getTokens', (WidgetTester tester) async {
        final GoogleSignInTokenData actualToken =
            await plugin.getTokens(email: expectedUserData.email);

        expect(actualToken, expectedTokenData);
      });

      testWidgets('requestScopes', (WidgetTester tester) async {
        final bool scopeGranted =
            await plugin.requestScopes(<String>['newScope']);

        expect(scopeGranted, isTrue);
      });
    });
  });

  group('auth2 Init successful, but exception on signIn() method', () {
    setUp(() async {
      // The pre-configured use case for the instances of the plugin in this test
      gapiUrl = toBase64Url(gapi_mocks.auth2SignInError());
      plugin = GoogleSignInPlugin();
      await plugin.initWithParams(const SignInInitParameters(
        hostedDomain: 'foo',
        scopes: <String>['some', 'scope'],
        clientId: '1234',
      ));
      await plugin.initialized;
    });

    testWidgets('User aborts sign in flow, throws PlatformException',
        (WidgetTester tester) async {
      await expectLater(plugin.signIn(), throwsA(isA<PlatformException>()));
    });

    testWidgets('User aborts sign in flow, error code is forwarded from JS',
        (WidgetTester tester) async {
      try {
        await plugin.signIn();
        fail('plugin.signIn() should have thrown an exception!');
      } catch (e) {
        final String code = js_util.getProperty<String>(e, 'code');
        expect(code, 'popup_closed_by_user');
      }
    });
  });
}
