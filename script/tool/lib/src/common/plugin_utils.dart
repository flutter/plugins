// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:flutter_plugin_tools/src/common/repository_package.dart';
import 'package:yaml/yaml.dart';

import 'core.dart';

/// Possible plugin support options for a platform.
enum PlatformSupport {
  /// The platform has an implementation in the package.
  inline,

  /// The platform has an endorsed federated implementation in another package.
  federated,
}

/// Returns whether the given [package] is a Flutter [platform] plugin.
///
/// It checks this by looking for the following pattern in the pubspec:
///
///     flutter:
///       plugin:
///         platforms:
///           [platform]:
///
/// If [requiredMode] is provided, the plugin must have the given type of
/// implementation in order to return true.
bool pluginSupportsPlatform(String platform, RepositoryPackage package,
    {PlatformSupport? requiredMode}) {
  assert(platform == kPlatformIos ||
      platform == kPlatformAndroid ||
      platform == kPlatformWeb ||
      platform == kPlatformMacos ||
      platform == kPlatformWindows ||
      platform == kPlatformLinux);
  try {
    final YamlMap pubspecYaml =
        loadYaml(package.pubspecFile.readAsStringSync()) as YamlMap;
    final YamlMap? flutterSection = pubspecYaml['flutter'] as YamlMap?;
    if (flutterSection == null) {
      return false;
    }
    final YamlMap? pluginSection = flutterSection['plugin'] as YamlMap?;
    if (pluginSection == null) {
      return false;
    }
    final YamlMap? platforms = pluginSection['platforms'] as YamlMap?;
    if (platforms == null) {
      // Legacy plugin specs are assumed to support iOS and Android. They are
      // never federated.
      if (requiredMode == PlatformSupport.federated) {
        return false;
      }
      if (!pluginSection.containsKey('platforms')) {
        return platform == kPlatformIos || platform == kPlatformAndroid;
      }
      return false;
    }
    final YamlMap? platformEntry = platforms[platform] as YamlMap?;
    if (platformEntry == null) {
      return false;
    }
    // If the platform entry is present, then it supports the platform. Check
    // for required mode if specified.
    final bool federated = platformEntry.containsKey('default_package');
    return requiredMode == null ||
        federated == (requiredMode == PlatformSupport.federated);
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}
