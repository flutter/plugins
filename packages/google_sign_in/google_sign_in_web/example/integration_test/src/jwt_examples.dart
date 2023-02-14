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
/// 'email': 'adultman@example.com',
/// 'sub': '123456',
/// 'name': 'Vincent Adultman',
/// 'picture': 'https://thispersondoesnotexist.com/image?x=.jpg',
///
/// Signed with HS256 and the private key: 'symmetric-encryption-is-weak'
final CredentialResponse okCredential =
    jsifyAs<CredentialResponse>(<String, Object?>{
  'credential':
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFkdWx0bWFuQGV4YW1wbGUuY29tIiwic3ViIjoiMTIzNDU2IiwibmFtZSI6IlZpbmNlbnQgQWR1bHRtYW4iLCJwaWN0dXJlIjoiaHR0cHM6Ly90aGlzcGVyc29uZG9lc25vdGV4aXN0LmNvbS9pbWFnZT94PS5qcGcifQ.lqzULA_U3YzEl_-fL7YLU-kFXmdD2ttJLTv-UslaNQ4',
});

// More encrypted credential responses may be created on https://jwt.io.
//
// First, decode the credential that's listed above, modify to your heart's
// content, and add a new credential here.
//
// (It can also be done with `package:jose` and `dart:convert`.)
