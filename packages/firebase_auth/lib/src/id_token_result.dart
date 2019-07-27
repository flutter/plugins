// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Represents ID token result obtained from [FirebaseUser], containing the
/// ID token JWT string and other helper properties for getting different
/// data associated with the token as well as all the decoded payload claims.
///
/// Note that these claims are not to be trusted as they are parsed client side.
/// Only server side verification can guarantee the integrity of the token
/// claims.
class IdTokenResult {
  @visibleForTesting
  IdTokenResult(this._data, this._app);

  final FirebaseApp _app;

  final Map<dynamic, dynamic> _data;

  /// The Firebase Auth ID token JWT string.
  String get token => _data['token'];

  /// The time when the ID token expires.
  DateTime get expirationTime =>
      DateTime.fromMillisecondsSinceEpoch(_data['expirationTimestamp'] * 1000);

  /// The time the user authenticated (signed in).
  ///
  /// Note that this is not the time the token was refreshed.
  DateTime get authTime =>
      DateTime.fromMillisecondsSinceEpoch(_data['authTimestamp'] * 1000);

  /// The time when ID token was issued.
  DateTime get issuedAtTime =>
      DateTime.fromMillisecondsSinceEpoch(_data['issuedAtTimestamp'] * 1000);

  /// The sign-in provider through which the ID token was obtained (anonymous,
  /// custom, phone, password, etc). Note, this does not map to provider IDs.
  String get signInProvider => _data['signInProvider'];

  /// The entire payload claims of the ID token including the standard reserved
  /// claims as well as the custom claims.
  Map<dynamic, dynamic> get claims => _data['claims'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
