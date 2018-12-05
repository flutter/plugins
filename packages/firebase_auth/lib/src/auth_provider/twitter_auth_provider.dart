// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

class TwitterAuthProvider {
  static final String providerId = 'twitter.com';

  static AuthCredential getCredential({
    @required String authToken,
    @required String authTokenSecret,
  }) {
    return AuthCredential._(providerId, <String, String>{
      'authToken': authToken,
      'authTokenSecret': authTokenSecret,
    });
  }
}
