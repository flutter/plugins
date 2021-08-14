// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

/// The linux implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for linux
class PathProviderLinux extends PathProviderPlatform {
  /// Constructs an instance of [PathProviderLinux]
  PathProviderLinux() : _environment = Platform.environment;

  /// Constructs an instance of [PathProviderLinux] with the given [environment]
  @visibleForTesting
  PathProviderLinux.private({
    required Map<String, String> environment,
  }) : _environment = environment;

  final Map<String, String> _environment;

  /// Registers this class as the default instance of [PathProviderPlatform]
  static void registerWith() {
    PathProviderPlatform.instance = PathProviderLinux();
  }

  @override
  Future<String?> getTemporaryPath() {
    final String environmentTmpDir = _environment['TMPDIR'] ?? '';
    return Future<String?>.value(
      environmentTmpDir.isEmpty ? '/tmp' : environmentTmpDir,
    );
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final String processName = path.basenameWithoutExtension(
        await File('/proc/self/exe').resolveSymbolicLinks());
    final Directory directory =
        Directory(path.join(xdg.dataHome.path, processName));
    // Creating the directory if it doesn't exist, because mobile implementations assume the directory exists
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return Future<String?>.value(xdg.getUserDirectory('DOCUMENTS')?.path);
  }

  @override
  Future<String?> getDownloadsPath() {
    return Future<String?>.value(xdg.getUserDirectory('DOWNLOAD')?.path);
  }
}
