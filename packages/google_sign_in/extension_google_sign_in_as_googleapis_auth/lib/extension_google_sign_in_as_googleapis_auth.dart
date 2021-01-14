// Copyright 2020 The Flutter Authors
//
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file or at
// https://developers.google.com/open-source/licenses/bsd

import 'package:meta/meta.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/auth.dart' as googleapis_auth;
import 'package:http/http.dart' as http;

/// Extension on [GoogleSignIn] that adds an `authenticatedClient` method.
///
/// This method can be used to retrieve an authenticated [googleapis_auth.AuthClient]
/// client that can be used with the rest of the `googleapis` libraries.
extension GoogleApisGoogleSignInAuth on GoogleSignIn {
  /// Retrieve a `googleapis` authenticated client.
  Future<googleapis_auth.AuthClient> authenticatedClient({
    @visibleForTesting GoogleSignInAuthentication debugAuthentication,
    @visibleForTesting List<String> debugScopes = const [],
  }) async {
    final auth = debugAuthentication ?? await currentUser.authentication;
    final credentials = googleapis_auth.AccessCredentials(
      googleapis_auth.AccessToken(
        'Bearer',
        auth.accessToken,
        // We don't know when the token expires, so we assume "never"
        DateTime.now().toUtc().add(Duration(days: 365)),
      ),
      null, // We don't have a refreshToken
      debugScopes ?? this.scopes,
    );

    return googleapis_auth.authenticatedClient(http.Client(), credentials);
  }
}
