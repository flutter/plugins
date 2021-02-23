// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart';

/// A set of allowed XTypes
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  ///
  /// A group with none of the type options provided indicates that any type is
  /// allowed.
  XTypeGroup({
    this.label,
    this.extensions,
    this.mimeTypes,
    this.macUTIs,
    this.webWildCards,
  }) {
    _verifyExtensions();
  }

  void _verifyExtensions() {
    if (extensions == null) return;
    final exts = extensions!;
    for (var i = 0; i < exts.length; i++) {
      if (!exts[i].startsWith('.')) continue;
      if (kDebugMode) {
        print('extensions[${i}] with value "${exts[i]}" is invalid.'
            ' The leading dots are being removed from the extensions'
            ' Please fix it.');
      }
      exts[i] = exts[i].substring(1);
    }
  }

  /// The 'name' or reference to this group of types
  final String? label;

  /// The extensions for this group
  final List<String>? extensions;

  /// The MIME types for this group
  final List<String>? mimeTypes;

  /// The UTIs for this group
  final List<String>? macUTIs;

  /// The web wild cards for this group (ex: image/*, video/*)
  final List<String>? webWildCards;

  /// Converts this object into a JSON formatted object
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'label': label,
      'extensions': extensions,
      'mimeTypes': mimeTypes,
      'macUTIs': macUTIs,
      'webWildCards': webWildCards,
    };
  }
}
