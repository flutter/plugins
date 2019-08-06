// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Interface representing a user's metadata.
class FirebaseUserMetadata {
  FirebaseUserMetadata._(this._data);

  final Map<String, dynamic> _data;

  /// When this account was created as dictated by the server clock.
  DateTime get creationTime =>
      DateTime.fromMillisecondsSinceEpoch(_data['creationTimestamp']);

  /// When the user last signed in as dictated by the server clock.
  ///
  /// This is only accurate up to a granularity of 2 minutes for consecutive sign-in attempts.
  DateTime get lastSignInTime =>
      DateTime.fromMillisecondsSinceEpoch(_data['lastSignInTimestamp']);
}
