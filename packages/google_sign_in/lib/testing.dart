// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';

class FakeSignInBackend {
  Map<String, String> _currentUser = <String, String>{};

  void setUser(Map<String, String> userData) {
    _currentUser = <String, String>{
      'displayName': userData['displayName'],
      'email': userData['email'],
      'id': userData['id'],
      'photoUrl': userData['photoUrl'],
      'idToken': userData['idToken']
    };
  }

  Future<dynamic> handleMethodCall(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init':
        // do nothing
        return null;
      case 'getTokens':
        return <String, String>{'idToken': _currentUser['idToken']};
      case 'signIn':
        return _currentUser;
      case 'signInSilently':
        return _currentUser;
      case 'disconnect':
        _currentUser = <String, String>{};
        return _currentUser;
    }
  }
}
