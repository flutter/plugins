// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

import 'core.dart';

/// Possible plugin support options for a platform.
enum PlatformSupport {
  /// The platform has an implementation in the package.
  inline,

  /// The platform has an endorsed federated implementation in another package.
  federated,
}

/// Returns whether the given directory contains a Flutter [platform] plugin.
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
bool pluginSupportsPlatform(String platform, FileSystemEntity entity,
    {PlatformSupport? requiredMode}) {
  assert(platform == kPlatformFlagIos ||
      platform == kPlatformFlagAndroid ||
      platform == kPlatformFlagWeb ||
      platform == kPlatformFlagMacos ||
      platform == kPlatformFlagWindows ||
      platform == kPlatformFlagLinux);
  if (entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile = entity.childFile('pubspec.yaml');
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
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
        return platform == kPlatformFlagIos || platform == kPlatformFlagAndroid;
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

/// Returns whether the given directory contains a Flutter Android plugin.
bool isAndroidPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagAndroid, entity);
}

/// Returns whether the given directory contains a Flutter iOS plugin.
bool isIosPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagIos, entity);
}

/// Returns whether the given directory contains a Flutter web plugin.
bool isWebPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagWeb, entity);
}

/// Returns whether the given directory contains a Flutter Windows plugin.
bool isWindowsPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagWindows, entity);
}

/// Returns whether the given directory contains a Flutter macOS plugin.
bool isMacOsPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagMacos, entity);
}

/// Returns whether the given directory contains a Flutter linux plugin.
bool isLinuxPlugin(FileSystemEntity entity) {
  return pluginSupportsPlatform(kPlatformFlagLinux, entity);
}
