// Copyright 2020 The Flutter Authors
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth.dart' as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';

// Mocks so I don't have to prepare all the GoogleSignIn environment.
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

const SOME_FAKE_ACCESS_TOKEN = 'this-is-something-not-null';
const SOME_FAKE_SCOPES = ['some-scope', 'another-scope'];

void main() {
  GoogleSignIn signIn = MockGoogleSignIn();
  final authMock = MockGoogleSignInAuthentication();

  setUp(() {
    when(authMock.accessToken).thenReturn(SOME_FAKE_ACCESS_TOKEN);
  });

  test('authenticatedClient returns an authenticated client', () async {
    final client = await signIn.authenticatedClient(
      debugAuthentication: authMock,
    );
    expect(client, isA<auth.AuthClient>());
  });

  test('authenticatedClient returned client contains the passed-in credentials',
      () async {
    final client = await signIn.authenticatedClient(
      debugAuthentication: authMock,
      debugScopes: SOME_FAKE_SCOPES,
    );
    expect(client.credentials.accessToken.data, equals(SOME_FAKE_ACCESS_TOKEN));
    expect(client.credentials.scopes, equals(SOME_FAKE_SCOPES));
  });
}
