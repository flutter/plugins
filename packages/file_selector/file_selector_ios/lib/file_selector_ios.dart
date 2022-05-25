// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

const MethodChannel _channel =
    MethodChannel('plugins.flutter.io/file_selector_ios');

/// An implementation of [FileSelectorPlatform] for iOS.
class FileSelectorIOS extends FileSelectorPlatform {
  /// The MethodChannel that is being used by this implementation of the plugin.
  @visibleForTesting
  MethodChannel get channel => _channel;

  /// Registers the iOS implementation.
  static void registerWith() {
    FileSelectorPlatform.instance = FileSelectorIOS();
  }

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    final List<String>? path = await _channel.invokeListMethod<String>(
      'openFile',
      <String, dynamic>{
        'acceptedTypes': _allowedTypeListFromTypeGroups(acceptedTypeGroups),
        'initialDirectory': initialDirectory,
        'confirmButtonText': confirmButtonText,
        'multiple': false,
      },
    );
    return path == null ? null : XFile(path.first);
  }

  // Converts the type group list into a flat list of all allowed types, since
  // iOS doesn't support filter groups.
  Map<String, List<String>>? _allowedTypeListFromTypeGroups(
      List<XTypeGroup>? typeGroups) {
    const String extensionKey = 'extensions';
    const String mimeTypeKey = 'mimeTypes';
    const String utiKey = 'UTIs';
    if (typeGroups == null || typeGroups.isEmpty) {
      return null;
    }
    final Map<String, List<String>> allowedTypes = <String, List<String>>{
      extensionKey: <String>[],
      mimeTypeKey: <String>[],
      utiKey: <String>[],
    };
    for (final XTypeGroup typeGroup in typeGroups) {
      // If any group allows everything, no filtering should be done.
      if ((typeGroup.extensions?.isEmpty ?? true) &&
          (typeGroup.macUTIs?.isEmpty ?? true) &&
          (typeGroup.mimeTypes?.isEmpty ?? true)) {
        return null;
      }
      allowedTypes[extensionKey]!.addAll(typeGroup.extensions ?? <String>[]);
      allowedTypes[mimeTypeKey]!.addAll(typeGroup.mimeTypes ?? <String>[]);
      allowedTypes[utiKey]!.addAll(typeGroup.macUTIs ?? <String>[]);
    }

    return allowedTypes;
  }
}
