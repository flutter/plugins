// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:jwt_decoder/jwt_decoder.dart' as jwt;

/// Converts a [CredentialResponse] into a [GoogleSignInUserData].
///
/// May return `null`, if the `credentialResponse` is null, or its `credential`
/// cannot be decoded.
GoogleSignInUserData? gisResponsesToUserData(
    CredentialResponse? credentialResponse) {
  if (credentialResponse == null || credentialResponse.credential == null) {
    return null;
  }

  final Map<String, Object?>? payload =
      jwt.JwtDecoder.tryDecode(credentialResponse.credential!);

  if (payload == null) {
    return null;
  }

  return GoogleSignInUserData(
    email: payload['email']! as String,
    id: payload['sub']! as String,
    displayName: payload['name']! as String,
    photoUrl: payload['picture']! as String,
    idToken: credentialResponse.credential,
  );
}

/// Converts responses from the GIS library into TokenData for the plugin.
GoogleSignInTokenData gisResponsesToTokenData(
    CredentialResponse? credentialResponse, TokenResponse? tokenResponse) {
  return GoogleSignInTokenData(
    idToken: credentialResponse?.credential,
    accessToken: tokenResponse?.access_token,
  );
}
