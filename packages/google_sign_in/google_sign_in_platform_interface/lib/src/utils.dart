// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../google_sign_in_platform_interface.dart';

/// Converts user data coming from native code into the proper platform interface type.
GoogleSignInUserData? getUserDataFromMap(Map<String, dynamic>? data) {
  if (data == null) {
    return null;
  }
  return GoogleSignInUserData(
      email: data['email']!,
      id: data['id']!,
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      idToken: data['idToken']);
}

/// Converts token data coming from native code into the proper platform interface type.
GoogleSignInTokenData getTokenDataFromMap(Map<String, dynamic> data) {
  return GoogleSignInTokenData(
    idToken: data['idToken'],
    accessToken: data['accessToken'],
    serverAuthCode: data['serverAuthCode'],
  );
}
