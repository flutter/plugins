// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:colorize/colorize.dart';
import 'package:file/file.dart';

/// The signature for a print handler for commands that allow overriding the
/// print destination.
typedef Print = void Function(Object? object);

/// Key for APK (Android) platform.
const String platformAndroid = 'android';

/// Key for IPA (iOS) platform.
const String platformIOS = 'ios';

/// Key for linux platform.
const String platformLinux = 'linux';

/// Key for macos platform.
const String platformMacOS = 'macos';

/// Key for Web platform.
const String platformWeb = 'web';

/// Key for windows platform.
const String platformWindows = 'windows';

/// Key for enable experiment.
const String kEnableExperiment = 'enable-experiment';

/// Target platforms supported by Flutter.
// ignore: public_member_api_docs
enum FlutterPlatform { android, ios, linux, macos, web, windows }

/// Returns whether the given directory is a Dart package.
bool isPackage(FileSystemEntity entity) {
  if (entity is! Directory) {
    return false;
  }
  // According to
  // https://dart.dev/guides/libraries/create-library-packages#what-makes-a-library-package
  // a package must also have a `lib/` directory, but in practice that's not
  // always true. flutter/plugins has some special cases (espresso, some
  // federated implementation packages) that don't have any source, so this
  // deliberately doesn't check that there's a lib directory.
  return entity.childFile('pubspec.yaml').existsSync();
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
