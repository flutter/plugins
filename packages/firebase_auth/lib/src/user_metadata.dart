// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Interface representing a user's metadata.
class FirebaseUserMetadata {
  FirebaseUserMetadata._(this._data);

  final Map<dynamic, dynamic> _data;

  int get creationTimestamp => _data['creationTimestamp'];

  int get lastSignInTimestamp => _data['lastSignInTimestamp'];
}
