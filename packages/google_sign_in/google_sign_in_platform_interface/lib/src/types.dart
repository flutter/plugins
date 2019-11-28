// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:quiver/core.dart';

enum SignInOption { standard, games }

class GoogleSignInUserData {
  GoogleSignInUserData(
      {this.displayName, this.email, this.id, this.photoUrl, this.idToken});
  String displayName;
  String email;
  String id;
  String photoUrl;
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
