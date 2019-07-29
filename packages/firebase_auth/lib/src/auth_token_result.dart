// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Result object that contains a Firebase Auth ID Token.
///
/// A data class containing the ID token JWT string and other properties
/// associated with the token including the decoded payload claims.
class AuthTokenResult {
  AuthTokenResult._(this.token, this._claims);

  final Map<String, dynamic> _claims;

  /// Firebase Auth ID Token.
  ///
  /// Useful for authenticating calls against your own backend. Verify the
  /// integrity and validity of the token in your server either by using our
  /// server SDKs or following the documentation.
  final String token;

  /// Returns the authentication time.
  ///
  /// This is the time the user authenticated (signed in) and not the time the
  /// token was refreshed.
  DateTime get authTime {
    final int milliseconds = _getValue('auth_time');
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Returns the time at which this ID token will expire
  DateTime get expirationTime {
    final int milliseconds = _getValue('exp');
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Returns the issued at time.
  ///
  /// This is the time the ID token was last refreshed and not the
  /// authentication time.
  DateTime get issuedAtTime {
    final int milliseconds = _getValue('iat');
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  /// Returns the sign-in provider through which the ID token was obtained.
  ///
  /// This can be anonymous, custom, phone, password, etc. Note, this does not
  /// map to provider IDs. For example, anonymous and custom authentications are
  /// not considered providers. We chose the name here to map the name used in
  /// the ID token.
  String get signInProvider {
    final Map<String, dynamic> firebaseClaims =
        Map<String, dynamic>.from(_claims['firebase']);
    return firebaseClaims == null ? null : firebaseClaims['sign_in_provider'];
  }

  /// Returns the entire payload claims of the ID token.
  ///
  /// This including the standard reserved claims as well as the custom claims
  /// (set by developer via Admin SDK). Developers should verify the ID token
  /// and parse claims from its payload on the backend and never trust this
  /// value on the client.
  ///
  /// Returns an empty map if no claims are present.
  Map<String, dynamic> get claims => _claims;

  int _getValue(String key) {
    final int value = _claims[key] ?? 0;
    return value * 1000;
  }
}
