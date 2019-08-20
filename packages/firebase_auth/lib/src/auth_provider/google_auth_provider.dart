// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class GoogleAuthProvider {
  static const String providerId = 'google.com';

  static AuthCredential getCredential({
    @required String idToken,
    @required String accessToken,
  }) {
    return AuthCredential._(providerId, <String, String>{
      'idToken': idToken,
      'accessToken': accessToken,
    });
  }
}
