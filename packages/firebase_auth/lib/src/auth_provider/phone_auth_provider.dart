// Copyright 2018, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of firebase_auth;

class PhoneAuthProvider {
  static final String providerId = 'phone';

  static AuthCredential getCredential({
    @required String verificationId,
    @required String smsCode,
  }) {
    return AuthCredential._(providerId, <String, String>{
      'verificationId': verificationId,
      'smsCode': smsCode,
    });
  }
}
