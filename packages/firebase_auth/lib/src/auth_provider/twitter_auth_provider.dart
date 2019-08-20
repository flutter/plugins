// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

class TwitterAuthProvider {
  static const String providerId = 'twitter.com';

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
