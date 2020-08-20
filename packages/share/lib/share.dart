// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:mime/mime.dart' show lookupMimeType;

/// Plugin for summoning a platform share sheet.
class Share {
  /// [MethodChannel] used to communicate with the platform side.
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/share');

  /// Summons the platform's share sheet to share text.
  ///
  /// Wraps the platform's native share dialog. Can share a text and/or a URL.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional [subject] parameter can be used to populate a subject if the
  /// user chooses to send an email.
  ///
  /// The optional [sharePositionOrigin] parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// May throw [PlatformException] or [FormatException]
  /// from [MethodChannel].
  static Future<void> share(
    String text, {
    String subject,
    Rect sharePositionOrigin,
  }) {
    assert(text != null);
    assert(text.isNotEmpty);
    final Map<String, dynamic> params = <String, dynamic>{
      'text': text,
      'subject': subject,
    };

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return channel.invokeMethod<void>('share', params);
  }

  /// Summons the platform's share sheet to share a single file.
  ///
  /// Wraps the platform's native share dialog. Can share a file.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional `sharePositionOrigin` parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// May throw [PlatformException] or [FormatException]
  /// from [MethodChannel].
  static Future<void> shareFile(
    File file, {
    String mimeType,
    String subject,
    String text,
    Rect sharePositionOrigin,
  }) {
    assert(file != null);
    assert(file.existsSync());

    return shareFiles(
      <File>[file],
      mimeTypes: <String>[mimeType ?? _mimeTypeForFile(file)],
      subject: subject,
      text: text,
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// Summons the platform's share sheet to share multiple files.
  ///
  /// Wraps the platform's native share dialog. Can share a file.
  /// It uses the `ACTION_SEND` Intent on Android and `UIActivityViewController`
  /// on iOS.
  ///
  /// The optional `sharePositionOrigin` parameter can be used to specify a global
  /// origin rect for the share sheet to popover from on iPads. It has no effect
  /// on non-iPads.
  ///
  /// May throw [PlatformException] or [FormatException]
  /// from [MethodChannel].
  static Future<void> shareFiles(
    List<File> files, {
    List<String> mimeTypes,
    String subject,
    String text,
    Rect sharePositionOrigin,
  }) {
    assert(files != null);
    assert(files.isNotEmpty);
    assert(files.every((file) => file.existsSync()));
    final Map<String, dynamic> params = <String, dynamic>{
      'paths': files.map((file) => file.path).toList(),
      'mimeTypes':
          mimeTypes ?? files.map((file) => _mimeTypeForFile(file)).toList(),
    };

    if (subject != null) params['subject'] = subject;
    if (text != null) params['text'] = text;

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return channel.invokeMethod('shareFiles', params);
  }

  static String _mimeTypeForFile(File file) {
    assert(file != null);
    return lookupMimeType(file.path) ?? 'application/octet-stream';
  }
}
