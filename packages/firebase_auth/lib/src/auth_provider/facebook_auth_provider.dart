// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class FacebookAuthProvider {
  static const String providerId = 'facebook.com';

  static AuthCredential getCredential({String accessToken}) {
    return AuthCredential._(
      providerId,
      <String, String>{'accessToken': accessToken},
    );
  }
}
