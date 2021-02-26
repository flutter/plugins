// Copyright 2020 The Flutter Authors
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/fake.dart';

const SOME_FAKE_ACCESS_TOKEN = 'this-is-something-not-null';
const DEBUG_FAKE_SCOPES = <String>['some-scope', 'another-scope'];
const SIGN_IN_FAKE_SCOPES = <String>['some-scope', 'another-scope'];

class FakeGoogleSignIn extends Fake implements GoogleSignIn {
  final List<String> scopes = SIGN_IN_FAKE_SCOPES;
}

class FakeGoogleSignInAuthentication extends Fake
    implements GoogleSignInAuthentication {
  final String accessToken = SOME_FAKE_ACCESS_TOKEN;
}

void main() {
  GoogleSignIn signIn = FakeGoogleSignIn();
  final authMock = FakeGoogleSignInAuthentication();

  test('authenticatedClient returns an authenticated client', () async {
    final client = await signIn.authenticatedClient(
      debugAuthentication: authMock,
    );
    expect(client, isA<auth.AuthClient>());
  });

  test('authenticatedClient uses GoogleSignIn scopes by default', () async {
    final client = (await signIn.authenticatedClient(
      debugAuthentication: authMock,
    ))!;
    expect(client.credentials.accessToken.data, equals(SOME_FAKE_ACCESS_TOKEN));
    expect(client.credentials.scopes, equals(SIGN_IN_FAKE_SCOPES));
  });

  test('authenticatedClient returned client contains the passed-in credentials',
      () async {
    final client = (await signIn.authenticatedClient(
      debugAuthentication: authMock,
      debugScopes: DEBUG_FAKE_SCOPES,
    ))!;
    expect(client.credentials.accessToken.data, equals(SOME_FAKE_ACCESS_TOKEN));
    expect(client.credentials.scopes, equals(DEBUG_FAKE_SCOPES));
  });
}
