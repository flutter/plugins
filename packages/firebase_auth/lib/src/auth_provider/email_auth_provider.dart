// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

class EmailAuthProvider {
  static const String providerId = 'password';

  static AuthCredential getCredential({
    String email,
    String password,
  }) {
    return AuthCredential._(providerId, <String, String>{
      'email': email,
      'password': password,
    });
  }

  static AuthCredential getCredentialWithLink({
    String email,
    String link,
  }) {
    return AuthCredential._(providerId, <String, String>{
      'email': email,
      'link': link,
    });
  }
}
