// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:google_identity_services_web/id.dart';
import 'package:jose/jose.dart';

import 'jsify_as.dart';

/// Wraps a key-value map of [claims] in a JWT token similar GIS'.
///
/// Note that the encryption of this token is weak, and this method should
/// only be used for tests!
CredentialResponse createJwt(Map<String, Object?>? claims) {
  String? credential;
  if (claims != null) {
    final JsonWebTokenClaims token = JsonWebTokenClaims.fromJson(claims);
    final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder();
    builder.jsonContent = token.toJson();
    builder.addRecipient(
        JsonWebKey.fromJson(<String, Object?>{
          'kty': 'oct',
          'k': base64.encode('symmetric-encryption-is-weak'.codeUnits),
        }),
        algorithm: 'HS256'); // bogus crypto, don't use this for prod!
    builder.setProtectedHeader('typ', 'JWT');
    credential = builder.build().toCompactSerialization();
  }
  return jsifyAs<CredentialResponse>(<String, Object?>{
    'credential': credential,
  });
}
