// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

  GoogleSignInTokenData expectedTokenData =
      GoogleSignInTokenData(idToken: '70k3n', accessToken: 'access_70k3n');

  GoogleSignInUserData expectedUserData = GoogleSignInUserData(
    displayName: 'Foo Bar',
    email: 'foo@example.com',
    id: '123',
    photoUrl: 'http://example.com/img.jpg',
    idToken: expectedTokenData.idToken,
  );

  late GoogleSignInPlugin plugin;

  group('plugin.init() throws a catchable exception', () {
    setUp(() {
      // The pre-configured use case for the instances of the plugin in this test
      gapiUrl = toBase64Url(gapi_mocks.auth2InitError());
      plugin = GoogleSignInPlugin();
    });

    testWidgets('init throws PlatformException', (WidgetTester tester) async {
      await expectLater(
          plugin.init(
            hostedDomain: 'foo',
            scopes: <String>['some', 'scope'],
            clientId: '1234',
          ),
          throwsA(isA<PlatformException>()));
    });

    testWidgets('init forwards error code from JS',
        (WidgetTester tester) async {
      try {
        await plugin.init(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        );
        fail('plugin.init should have thrown an exception!');
      } catch (e) {
        final String code = js_util.getProperty(e, 'code') as String;
        expect(code, 'idpiframe_initialization_failed');
      }
    });
  });

  group('other methods also throw catchable exceptions on init fail', () {
    // This function ensures that init gets called, but for some reason, we
    // ignored that it has thrown stuff...
    Future<void> _discardInit() async {
      try {
        await plugin.init(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        );
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
      await expectLater(plugin.requestScopes(['newScope']),
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
      expect(plugin.init(hostedDomain: ''), throwsAssertionError);
    });

    testWidgets('Init doesn\'t accept spaces in scopes',
        (WidgetTester tester) async {
      expect(
          plugin.init(
            hostedDomain: '',
            clientId: '',
            scopes: <String>['scope with spaces'],
          ),
          throwsAssertionError);
    });

    group('Successful .init, then', () {
      setUp(() async {
        await plugin.init(
          hostedDomain: 'foo',
          scopes: <String>['some', 'scope'],
          clientId: '1234',
        );
        await plugin.initialized;
      });

      testWidgets('signInSilently', (WidgetTester tester) async {
        GoogleSignInUserData actualUser = (await plugin.signInSilently())!;

        expect(actualUser, expectedUserData);
      });

      testWidgets('signIn', (WidgetTester tester) async {
        GoogleSignInUserData actualUser = (await plugin.signIn())!;

        expect(actualUser, expectedUserData);
      });

      testWidgets('getTokens', (WidgetTester tester) async {
        GoogleSignInTokenData actualToken =
            await plugin.getTokens(email: expectedUserData.email);

        expect(actualToken, expectedTokenData);
      });

      testWidgets('requestScopes', (WidgetTester tester) async {
        bool scopeGranted = await plugin.requestScopes(['newScope']);

        expect(scopeGranted, isTrue);
      });
    });
  });

  group('auth2 Init successful, but exception on signIn() method', () {
    setUp(() async {
      // The pre-configured use case for the instances of the plugin in this test
      gapiUrl = toBase64Url(gapi_mocks.auth2SignInError());
      plugin = GoogleSignInPlugin();
      await plugin.init(
        hostedDomain: 'foo',
        scopes: <String>['some', 'scope'],
        clientId: '1234',
      );
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
        final String code = js_util.getProperty(e, 'code') as String;
        expect(code, 'popup_closed_by_user');
      }
    });
  });
}
