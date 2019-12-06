// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:quiver/core.dart';

/// Holds default configuration options to use when signing in.
enum SignInOption {
  /// Default configuration. Provides stable user ID and basic profile information.
  standard,

  /// Recommended configuration for Games sign in.
  games
}

/// Data struct representing information about the signed in user.
class GoogleSignInUserData {
  /// Uses the given data to construct an instance. Any of these parameters
  /// could be null.
  GoogleSignInUserData(
      {this.displayName, this.email, this.id, this.photoUrl, this.idToken});

  /// The human readable display name of the signed in user.
  String displayName;

  /// The email address of the signed in user. This may change over time and is
  /// not a unique identifier.
  String email;

  /// A token uniquely identifying the account.
  String id;

  /// A URL to the profile picture of the user.
  String photoUrl;

  /// An token that can be sent to your own server to verify the authentication
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

class GoogleSignInTokenData {
  GoogleSignInTokenData({this.idToken, this.accessToken});
  String idToken;
  String accessToken;

  @override
  int get hashCode => hash2(idToken, accessToken);

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInTokenData) return false;
    final GoogleSignInTokenData otherTokenData = other;
    return otherTokenData.idToken == idToken &&
        otherTokenData.accessToken == accessToken;
  }
}
