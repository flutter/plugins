// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:quiver/core.dart';

/// Default configuration options to use when signing in.
///
/// See also https://developers.google.com/android/reference/com/google/android/gms/auth/api/signin/GoogleSignInOptions
enum SignInOption {
  /// Default configuration. Provides stable user ID and basic profile information.
  ///
  /// See also https://developers.google.com/android/reference/com/google/android/gms/auth/api/signin/GoogleSignInOptions.html#DEFAULT_SIGN_IN.
  standard,

  /// Recommended configuration for Games sign in.
  ///
  /// This is currently only supported on Android and will throw an error if used
  /// on other platforms.
  ///
  /// See also https://developers.google.com/android/reference/com/google/android/gms/auth/api/signin/GoogleSignInOptions.html#public-static-final-googlesigninoptions-default_games_sign_in.
  games
}

/// Holds information about the signed in user.
class GoogleSignInUserData {
  /// Uses the given data to construct an instance. Any of these parameters
  /// could be null.
  GoogleSignInUserData(
      {this.displayName, this.email, this.id, this.photoUrl, this.idToken});

  /// The display name of the signed in user.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  String displayName;

  /// The email address of the signed in user.
  ///
  /// Applications should not key users by email address since a Google account's
  /// email address can change. Use [id] as a key instead.
  ///
  /// _Important_: Do not use this returned email address to communicate the
  /// currently signed in user to your backend server. Instead, send an ID token
  /// which can be securely validated on the server. See [idToken].
  String email;

  /// The unique ID for the Google account.
  ///
  /// This is the preferred unique key to use for a user record.
  ///
  /// _Important_: Do not use this returned Google ID to communicate the
  /// currently signed in user to your backend server. Instead, send an ID token
  /// which can be securely validated on the server. See [idToken].
  String id;

  /// The photo url of the signed in user if the user has a profile picture.
  ///
  /// Not guaranteed to be present for all users, even when configured.
  String photoUrl;

  /// A token that can be sent to your own server to verify the authentication
  /// data.
  String idToken;

  @override
  int get hashCode =>
      hashObjects(<String>[displayName, email, id, photoUrl, idToken]);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInUserData) return false;
    final GoogleSignInUserData otherUserData = other;
    return otherUserData.displayName == displayName &&
        otherUserData.email == email &&
        otherUserData.id == id &&
        otherUserData.photoUrl == photoUrl &&
        otherUserData.idToken == idToken;
  }
}

/// Holds authentication data after sign in.
class GoogleSignInTokenData {
  /// Either or both parameters may be null.
  GoogleSignInTokenData({
    this.idToken,
    this.accessToken,
    this.serverAuthCode,
  });

  /// An OpenID Connect ID token for the authenticated user.
  String idToken;

  /// The OAuth2 access token used to access Google services.
  String accessToken;

  /// Server auth code used to access Google Login
  String serverAuthCode;

  @override
  int get hashCode => hash3(idToken, accessToken, serverAuthCode);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInTokenData) return false;
    final GoogleSignInTokenData otherTokenData = other;
    return otherTokenData.idToken == idToken &&
        otherTokenData.accessToken == accessToken &&
        otherTokenData.serverAuthCode == serverAuthCode;
  }
}
