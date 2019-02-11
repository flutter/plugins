// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;

/// Plugin for summoning a platform share sheet.
class Share {
  /// [MethodChannel] used to communicate with the platform side.
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/share');

  /// Summons the platform's share sheet to share text.
  ///
  /// Wraps the platform's native share dialog. Can share a text and/or a URL.
  /// It uses the ACTION_SEND Intent on Android and UIActivityViewController
  /// on iOS.
  ///
  /// The optional `sharePositionOrigin` parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// May throw [PlatformException] or [FormatException]
  /// from [MethodChannel].
  static Future<void> share(String text, {Rect sharePositionOrigin}) {
    assert(text != null);
    assert(text.isNotEmpty);
    final Map<String, dynamic> params = <String, dynamic>{
      'text': text,
    };

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return channel.invokeMethod('share', params);
  }

  /// Summons the platform's share sheet to share a file.
  ///
  /// Wraps the platform's native share dialog. Can share a file.
  /// It uses the ACTION_SEND Intent on Android and UIActivityViewController
  /// on iOS.
  ///
  /// The optional `sharePositionOrigin` parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// May throw [PlatformException] or [FormatException]
  /// from [MethodChannel].
  static Future<void> shareFile(File file,
      {String mimeType,
      String subject,
      String text,
      Rect sharePositionOrigin}) {
    assert(file != null);
    assert(file.existsSync());
    final Map<String, dynamic> params = <String, dynamic>{
      'path': file.path,
      'mimeType': mimeType ?? _mimeTypeForFile(file),
    };

    if (subject != null) params['subject'] = subject;
    if (text != null) params['text'] = text;

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return channel.invokeMethod('shareFile', params);
  }

  static String _mimeTypeForFile(File file) {
    assert(file != null);
    final String path = file.path;

    final int extensionIndex = path.lastIndexOf("\.");
    if (extensionIndex == -1 || extensionIndex == 0) {
      return null;
    }

    final String extension = path.substring(extensionIndex + 1);
    switch (extension) {
      // image
      case 'jpeg':
      case 'jpg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'png':
        return 'image/png';
      case 'svg':
        return 'image/svg+xml';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      // audio
      case 'aac':
        return 'audio/aac';
      case 'oga':
        return 'audio/ogg';
      // video
      case 'avi':
        return 'video/x-msvideo';
      case 'mpeg':
        return 'video/mpeg';
      case 'ogv':
        return 'video/ogg';
      // other
      case 'csv':
        return 'text/csv';
      case 'htm':
      case 'html':
        return 'text/html';
      case 'json':
        return 'application/json';
      case 'pdf':
        return 'application/pdf';
      case 'txt':
        return 'text/plain';
    }
    return null;
  }
}
