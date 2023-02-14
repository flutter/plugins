// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_identity_services_web/id.dart';

import 'jsify_as.dart';

/// A JWT token with null `credential`.
final CredentialResponse nullCredential =
    jsifyAs<CredentialResponse>(<String, Object?>{
  'credential': null,
});

/// A JWT token for predefined values.
///
/// 'email': 'test@example.com',
/// 'sub': '123456',
/// 'name': 'Test McTestface',
/// 'picture': 'https://thispersondoesnotexist.com/image',
///
/// Signed with HS256 and the private key: 'symmetric-encryption-is-weak'
final CredentialResponse okCredential =
    jsifyAs<CredentialResponse>(<String, Object?>{
  'credential':
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20iLCJzdWIiOiIxMjM0NTYiLCJuYW1lIjoiVGVzdCBNY1Rlc3RmYWNlIiwicGljdHVyZSI6Imh0dHBzOi8vdGhpc3BlcnNvbmRvZXNub3RleGlzdC5jb20vaW1hZ2UifQ.pDNaEns4DYZZu6-GeWdgwo1QNcKCCHXEVs26vPD_Rnk',
});

// The following code can be useful to generate new `CredentialResponse`s as
// examples. It is implemented using package:jose and dart:convert.
//
// Wraps a key-value map of [claims] in a JWT token similar GIS's.
//
// Note that the encryption of this token is weak, and this method should
// only be used for tests!
// CredentialResponse createJwt(Map<String, Object?>? claims) {
//   String? credential;
//   if (claims != null) {
//     final JsonWebTokenClaims token = JsonWebTokenClaims.fromJson(claims);
//     final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder();
//     builder.jsonContent = token.toJson();
//     builder.addRecipient(
//         JsonWebKey.fromJson(<String, Object?>{
//           'kty': 'oct',
//           'k': base64.encode('symmetric-encryption-is-weak'.codeUnits),
//         }),
//         algorithm: 'HS256'); // bogus crypto, don't use this for prod!
//     builder.setProtectedHeader('typ', 'JWT');
//     credential = builder.build().toCompactSerialization();
//   }
//   return jsifyAs<CredentialResponse>(<String, Object?>{
//     'credential': credential,
//   });
// }
