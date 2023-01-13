// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jose/jose.dart';
import 'package:js/js_util.dart' as js_util;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gisResponsesToTokenData', () {
    testWidgets('null objects -> no problem', (WidgetTester tester) async {
      final GoogleSignInTokenData tokens = gisResponsesToTokenData(null, null);
      expect(tokens.accessToken, isNull);
      expect(tokens.idToken, isNull);
      expect(tokens.serverAuthCode, isNull);
    });

    testWidgets('non-null objects are correctly used', (WidgetTester tester) async {
      const String expectedIdToken = 'some-value-for-testing';
      const String expectedAccessToken = 'another-value-for-testing';

      final CredentialResponse credential = jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': expectedIdToken,
      });
      final TokenResponse token = jsifyAs<TokenResponse>(<String, Object?> {
        'access_token': expectedAccessToken,
      });
      final GoogleSignInTokenData tokens = gisResponsesToTokenData(credential, token);
      expect(tokens.accessToken, expectedAccessToken);
      expect(tokens.idToken, expectedIdToken);
      expect(tokens.serverAuthCode, isNull);
    });

  });

  group('gisResponsesToUserData', () {
    testWidgets('happy case', (WidgetTester tester) async {
      final CredentialResponse response = createJwt(<String, Object?>{
        'email': 'test@example.com',
        'sub': '123456',
        'name': 'Test McTestface',
        'picture': 'https://thispersondoesnotexist.com/image',
      });

      final GoogleSignInUserData data = gisResponsesToUserData(response)!;

      expect(data.displayName, 'Test McTestface');
      expect(data.id, '123456');
      expect(data.email, 'test@example.com');
      expect(data.photoUrl, 'https://thispersondoesnotexist.com/image');
      expect(data.idToken, response.credential);
    });

    testWidgets('null response -> null', (WidgetTester tester) async {
      expect(gisResponsesToUserData(null), isNull);
    });

    testWidgets('null response.credential -> null', (WidgetTester tester) async {
      final CredentialResponse response = createJwt(null);
      expect(gisResponsesToUserData(response), isNull);
    });

    testWidgets('invalid payload -> null', (WidgetTester tester) async {
      final CredentialResponse response = jsifyAs<CredentialResponse>(<String, Object?>{
        'credential': 'some-bogus.thing-that-is-not.valid-jwt',
      });
      expect(gisResponsesToUserData(response), isNull);
    });
  });
}

CredentialResponse createJwt(Map<String, Object?>? claims) {
  String? credential;
  if (claims != null) {
    final JsonWebTokenClaims token = JsonWebTokenClaims.fromJson(claims);
    final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder();
    builder.jsonContent = token.toJson();
    builder.addRecipient(JsonWebKey.fromJson(<String, Object?>{
      'kty': 'oct',
      'k': base64.encode('symmetric-encryption-is-weak'.codeUnits),
    }), algorithm: 'HS256'); // bogus crypto, don't use this for prod!
    builder.setProtectedHeader('typ', 'JWT');
    credential = builder.build().toCompactSerialization();

    print('Generated JWT: $credential');
  }
  return jsifyAs<CredentialResponse>(<String, Object?>{
    'credential': credential,
  });
}

T jsifyAs<T>(Map<String, Object?> data) {
  return js_util.jsify(data) as T;
}
