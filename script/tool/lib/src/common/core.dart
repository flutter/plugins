// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

/// The signature for a print handler for commands that allow overriding the
/// print destination.
typedef Print = void Function(Object? object);

/// Key for windows platform.
const String kPlatformWindows = 'windows';

/// Key for macos platform.
const String kPlatformMacos = 'macos';

/// Key for linux platform.
const String kPlatformLinux = 'linux';

/// Key for IPA (iOS) platform.
const String kPlatformIos = 'ios';

/// Key for APK (Android) platform.
const String kPlatformAndroid = 'android';

/// Key for Web platform.
const String kPlatformWeb = 'web';

/// Key for enable experiment.
const String kEnableExperiment = 'enable-experiment';

/// Returns whether the given directory contains a Flutter package.
bool isFlutterPackage(FileSystemEntity entity) {
  if (entity is! Directory) {
    return false;
  }

  try {
    final File pubspecFile = entity.childFile('pubspec.yaml');
    final YamlMap pubspecYaml =
        loadYaml(pubspecFile.readAsStringSync()) as YamlMap;
    final YamlMap? dependencies = pubspecYaml['dependencies'] as YamlMap?;
    if (dependencies == null) {
      return false;
    }
    return dependencies.containsKey('flutter');
  } on FileSystemException {
    return false;
  } on YamlException {
    return false;
  }
}

/// Prints `errorMessage` in red.
void printError(String errorMessage) {
  final Colorize redError = Colorize(errorMessage)..red();
  print(redError);
}

/// Error thrown when a command needs to exit with a non-zero exit code.
class ToolExit extends Error {
  /// Creates a tool exit with the given [exitCode].
  ToolExit(this.exitCode);

  /// The code that the process should exit with.
  final int exitCode;
}
