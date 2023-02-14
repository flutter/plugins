// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

import 'src/jsify_as.dart';
import 'src/jwt_examples.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gisResponsesToTokenData', () {
    testWidgets('null objects -> no problem', (_) async {
      final GoogleSignInTokenData tokens = gisResponsesToTokenData(null, null);
      expect(tokens.accessToken, isNull);
      expect(tokens.idToken, isNull);
      expect(tokens.serverAuthCode, isNull);
    });

    testWidgets('non-null objects are correctly used', (_) async {
      const String expectedIdToken = 'some-value-for-testing';
      const String expectedAccessToken = 'another-value-for-testing';

      final CredentialResponse credential =
          jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': expectedIdToken,
      });
      final TokenResponse token = jsifyAs<TokenResponse>(<String, Object?>{
        'access_token': expectedAccessToken,
      });
      final GoogleSignInTokenData tokens =
          gisResponsesToTokenData(credential, token);
      expect(tokens.accessToken, expectedAccessToken);
      expect(tokens.idToken, expectedIdToken);
      expect(tokens.serverAuthCode, isNull);
    });
  });

  group('gisResponsesToUserData', () {
    testWidgets('happy case', (_) async {
      final GoogleSignInUserData data = gisResponsesToUserData(okCredential)!;

      expect(data.displayName, 'Vincent Adultman');
      expect(data.id, '123456');
      expect(data.email, 'adultman@example.com');
      expect(data.photoUrl, 'https://thispersondoesnotexist.com/image?x=.jpg');
      expect(data.idToken, okCredential.credential);
    });

    testWidgets('null response -> null', (_) async {
      expect(gisResponsesToUserData(null), isNull);
    });

    testWidgets('null response.credential -> null', (_) async {
      final CredentialResponse response = nullCredential;
      expect(gisResponsesToUserData(response), isNull);
    });

    testWidgets('invalid payload -> null', (_) async {
      final CredentialResponse response =
          jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': 'some-bogus.thing-that-is-not.valid-jwt',
      });
      expect(gisResponsesToUserData(response), isNull);
    });
  });
}
