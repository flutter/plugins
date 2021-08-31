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

/// Returns true if [package] is a Flutter [platform] plugin.
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
bool pluginSupportsPlatform(
  String platform,
  RepositoryPackage plugin, {
  PlatformSupport? requiredMode,
  String? variant,
}) {
  assert(platform == kPlatformIos ||
      platform == kPlatformAndroid ||
      platform == kPlatformWeb ||
      platform == kPlatformMacos ||
      platform == kPlatformWindows ||
      platform == kPlatformLinux);
  try {
    final YamlMap? platformEntry =
        _readPlatformPubspecSectionForPlugin(platform, plugin);
    if (platformEntry == null) {
      return false;
    }

    // If the platform entry is present, then it supports the platform. Check
    // for required mode if specified.
    if (requiredMode != null) {
      final bool federated = platformEntry.containsKey('default_package');
      if (federated != (requiredMode == PlatformSupport.federated)) {
        return false;
      }
    }

    // If a variant is specified, check for that variant.
    if (variant != null) {
      const String variantsKey = 'supportedVariants';
      if (platformEntry.containsKey(variantsKey)) {
        if (!(platformEntry['supportedVariants']! as YamlList)
            .contains(variant)) {
          return false;
        }
      } else {
        // Platforms with variants have a default variant when unspecified for
        // backward compatibility. Must match the flutter tool logic.
        const Map<String, String> defaultVariants = <String, String>{
          kPlatformWindows: platformVariantWin32,
        };
        if (variant != defaultVariants[platform]) {
          return false;
        }
      }
    }

    return true;
  } on YamlException {
    return false;
  }
}

/// Returns true if [plugin] includes native code for [platform], as opposed to
/// being implemented entirely in Dart.
bool pluginHasNativeCodeForPlatform(String platform, RepositoryPackage plugin) {
  if (platform == kPlatformWeb) {
    // Web plugins are always Dart-only.
    return false;
  }
  try {
    final YamlMap? platformEntry =
        _readPlatformPubspecSectionForPlugin(platform, plugin);
    if (platformEntry == null) {
      return false;
    }
    // All other platforms currently use pluginClass for indicating the native
    // code in the plugin.
    final String? pluginClass = platformEntry['pluginClass'] as String?;
    // TODO(stuartmorgan): Remove the check for 'none' once none of the plugins
    // in the repository use that workaround. See
    // https://github.com/flutter/flutter/issues/57497 for context.
    return pluginClass != null && pluginClass != 'none';
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}

/// Returns the
///   flutter:
///     plugin:
///       platforms:
///         [platform]:
/// section from [plugin]'s pubspec.yaml, or null if either it is not present,
/// or the pubspec couldn't be read.
YamlMap? _readPlatformPubspecSectionForPlugin(
    String platform, RepositoryPackage plugin) {
  try {
    final File pubspecFile = plugin.pubspecFile;
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final YamlMap? flutterSection = pubspecYaml['flutter'] as YamlMap?;
    if (flutterSection == null) {
      return null;
    }
    final YamlMap? pluginSection = flutterSection['plugin'] as YamlMap?;
    if (pluginSection == null) {
      return null;
    }
    final YamlMap? platforms = pluginSection['platforms'] as YamlMap?;
    if (platforms == null) {
      return null;
    }
    return platforms[platform] as YamlMap?;
  } on FileSystemException {
    return null;
  } on YamlException {
    return null;
  }
}
