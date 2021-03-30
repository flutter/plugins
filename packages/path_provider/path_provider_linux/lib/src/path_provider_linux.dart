// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'dart:io';
import 'dart:async';

import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'get_application_id.dart';

/// The linux implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for linux
class PathProviderLinux extends PathProviderPlatform {
  /// Registers this class as the default instance of [PathProviderPlatform]
  static void register() {
    PathProviderPlatform.instance = PathProviderLinux();
  }

  @override
  Future<String?> getTemporaryPath() {
    return Future.value("/tmp");
  }

  // Gets the name of this executable.
  Future<String> _getExecutableName() async {
    return path.basenameWithoutExtension(
        await File('/proc/self/exe').resolveSymbolicLinks());
  }

  // Gets the unique ID for this application.
  Future<String> _getId() async {
    var appId = getApplicationId();
    if (appId != null) return appId;

    // Fall back to using the executable name.
    return await _getExecutableName();
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    // This plugin originally used the executable name as a directory.
    // Use that if it exists for backwards compatibility.
    final legacyDirectory =
        Directory(path.join(xdg.dataHome.path, await _getExecutableName()));
    if (await legacyDirectory.exists()) {
      return legacyDirectory.path;
    }

    final directory = Directory(path.join(xdg.dataHome.path, await _getId()));
    // Creating the directory if it doesn't exist, because mobile implementations assume the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return Future.value(xdg.getUserDirectory('DOCUMENTS')?.path);
  }

  @override
  Future<String?> getDownloadsPath() {
    return Future.value(xdg.getUserDirectory('DOWNLOAD')?.path);
  }
}
