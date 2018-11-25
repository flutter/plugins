// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

class FacebookAuthProvider {
  static final String providerId = 'facebook.com';

  static AuthCredential getCredential({String accessToken}) {
    return AuthCredential._(
      providerId,
      <String, String>{'accessToken': accessToken},
    );
  }
}
