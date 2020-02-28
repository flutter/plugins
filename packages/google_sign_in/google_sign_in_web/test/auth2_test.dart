// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'gapi_mocks/gapi_mocks.dart' as gapi_mocks;
import 'utils.dart';

void main() {
  GoogleSignInTokenData expectedTokenData =
      GoogleSignInTokenData(idToken: '70k3n', accessToken: 'access_70k3n');

  GoogleSignInUserData expectedUserData = GoogleSignInUserData(
    displayName: 'Foo Bar',
    email: 'foo@example.com',
    id: '123',
    photoUrl: 'http://example.com/img.jpg',
    idToken: expectedTokenData.idToken,
  );

  // The pre-configured use case for the instances of the plugin in this test
  gapiUrl = toBase64Url(gapi_mocks.auth2InitSuccess(expectedUserData));

  GoogleSignInPlugin plugin;

  setUp(() {
    plugin = GoogleSignInPlugin();
  });

  test('Init requires clientId', () async {
    expect(plugin.init(hostedDomain: ''), throwsAssertionError);
  });

  test('Init doesn\'t accept spaces in scopes', () async {
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

    test('signInSilently', () async {
      GoogleSignInUserData actualUser = await plugin.signInSilently();

      expect(actualUser, expectedUserData);
    });

    test('signIn', () async {
      GoogleSignInUserData actualUser = await plugin.signIn();

      expect(actualUser, expectedUserData);
    });

    test('getTokens', () async {
      GoogleSignInTokenData actualToken =
          await plugin.getTokens(email: expectedUserData.email);

      expect(actualToken, expectedTokenData);
    });

    test('requestScopes', () async {
      bool scopeGranted = await plugin.requestScopes(['newScope']);

      expect(scopeGranted, isTrue);
    });
  });
}
