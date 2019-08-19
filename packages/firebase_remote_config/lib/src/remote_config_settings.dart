// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_remote_config;

/// RemoteConfigSettings can be used to configure how Remote Config operates.
class RemoteConfigSettings {
  RemoteConfigSettings({this.debugMode = false});

  /// Enable or disable developer mode for Remote Config.
  ///
  /// When set to true developer mode is enabled, when set to false developer
  /// mode is disabled. When developer mode is enabled fetch throttling is
  /// relaxed to allow many more fetch calls per hour to the remote server than
  /// the 5 per hour that is enforced when developer mode is disabled.
  final bool debugMode;
}
