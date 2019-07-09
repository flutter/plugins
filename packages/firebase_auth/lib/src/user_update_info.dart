// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Represents user profile data that can be updated by [updateProfile]
///
/// The purpose of having separate class with a map is to give possibility
/// to check if value was set to null or not provided
class UserUpdateInfo {
  /// Container of data that will be send in update request
  final Map<String, String> _updateData = <String, String>{};

  set displayName(String displayName) =>
      _updateData['displayName'] = displayName;

  String get displayName => _updateData['displayName'];

  set photoUrl(String photoUri) => _updateData['photoUrl'] = photoUri;

  String get photoUrl => _updateData['photoUrl'];
}
