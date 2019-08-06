// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Result object obtained from operations that can affect the authentication
/// state. Contains a method that returns the currently signed-in user after
/// the operation has completed.
class AuthResult {
  AuthResult._(this._data, FirebaseApp app)
      : user = FirebaseUser._(_data['user'].cast<String, dynamic>(), app);

  final Map<String, dynamic> _data;

  /// Returns the currently signed-in [FirebaseUser], or `null` if there isn't
  /// any (i.e. the user is signed out).
  final FirebaseUser user;

  /// Returns IDP-specific information for the user if the provider is one of
  /// Facebook, Github, Google, or Twitter.
  AdditionalUserInfo get additionalUserInfo =>
      _data['additionalUserInfo'] == null
          ? null
          : AdditionalUserInfo._(_data['additionalUserInfo']);

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
