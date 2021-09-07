// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';
import 'package:yaml/yaml.dart';

/// The signature for a print handler for commands that allow overriding the
/// print destination.
typedef Print = void Function(Object? object);

/// Key for APK (Android) platform.
const String kPlatformAndroid = 'android';

/// Key for IPA (iOS) platform.
const String kPlatformIos = 'ios';

/// Key for linux platform.
const String kPlatformLinux = 'linux';

/// Key for macos platform.
const String kPlatformMacos = 'macos';

/// Key for Web platform.
const String kPlatformWeb = 'web';

/// Key for windows platform.
///
/// Note that this corresponds to the Win32 variant for flutter commands like
/// `build` and `run`, but is a general platform containing all Windows
/// variants for purposes of the `platform` section of a plugin pubspec).
const String kPlatformWindows = 'windows';

/// Key for WinUWP platform.
///
/// Note that UWP is a platform for the purposes of flutter commands like
/// `build` and `run`, but a variant of the `windows` platform for the purposes
/// of plugin pubspecs).
const String kPlatformWinUwp = 'winuwp';

/// Key for Win32 variant of the Windows platform.
const String platformVariantWin32 = 'win32';

/// Key for UWP variant of the Windows platform.
///
/// See the note on [kPlatformWinUwp].
const String platformVariantWinUwp = 'uwp';

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

/// Prints `successMessage` in green.
void printSuccess(String successMessage) {
  print(Colorize(successMessage)..green());
}

/// Prints `errorMessage` in red.
void printError(String errorMessage) {
  print(Colorize(errorMessage)..red());
}

/// Error thrown when a command needs to exit with a non-zero exit code.
///
/// While there is no specific definition of the meaning of different non-zero
/// exit codes for this tool, commands should follow the general convention:
///   1: The command ran correctly, but found errors.
///   2: The command failed to run because the arguments were invalid.
///  >2: The command failed to run correctly for some other reason. Ideally,
///      each such failure should have a unique exit code within the context of
///      that command.
class ToolExit extends Error {
  /// Creates a tool exit with the given [exitCode].
  ToolExit(this.exitCode);

  /// The code that the process should exit with.
  final int exitCode;
}

/// A exit code for [ToolExit] for a successful run that found errors.
const int exitCommandFoundErrors = 1;

/// A exit code for [ToolExit] for a failure to run due to invalid arguments.
const int exitInvalidArguments = 2;
