// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

class GithubAuthProvider {
  static const String providerId = 'github.com';

  static AuthCredential getCredential({@required String token}) {
    return AuthCredential._(providerId, <String, String>{'token': token});
  }
}
