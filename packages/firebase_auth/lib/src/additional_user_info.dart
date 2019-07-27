// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Interface representing a user's additional information
class AdditionalUserInfo {
  AdditionalUserInfo._(this._data);

  final Map<dynamic, dynamic> _data;

  /// Returns whether the user is new or existing
  bool get isNewUser => _data['isNewUser'];

  /// Returns the username if the provider is GitHub or Twitter
  String get username => _data['username'];

  /// Returns the provider ID for specifying which provider the
  /// information in [profile] is for.
  String get providerId => _data['providerId'];

  /// Returns a Map containing IDP-specific user data if the provider
  /// is one of Facebook, GitHub, Google, Twitter, Microsoft, or Yahoo.
  Map<String, dynamic> get profile => _data['profile']?.cast<String, dynamic>();
}
