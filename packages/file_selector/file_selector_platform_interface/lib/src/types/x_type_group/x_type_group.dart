// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter/foundation.dart' show immutable;

/// A set of allowed XTypes.
@immutable
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  ///
  /// A group with none of the type options provided indicates that any type is
  /// allowed.
  const XTypeGroup({
    this.label,
    List<String>? extensions,
    this.mimeTypes,
    List<String>? macUTIs,
    List<String>? uniformTypeIdentifiers,
    this.webWildCards,
  })  : _extensions = extensions,
        assert(uniformTypeIdentifiers == null || macUTIs == null,
            'It is only allowed to specify either macUTIs or uniformTypeIdentifiers'),
        uniformTypeIdentifiers = uniformTypeIdentifiers ?? macUTIs;

  /// The 'name' or reference to this group of types.
  final String? label;

  /// The MIME types for this group.
  final List<String>? mimeTypes;

  /// The uniform type identifiers for this group
  final List<String>? uniformTypeIdentifiers;

  /// The web wild cards for this group (ex: image/*, video/*).
  final List<String>? webWildCards;

  final List<String>? _extensions;

  /// The extensions for this group.
  List<String>? get extensions {
    return _removeLeadingDots(_extensions);
  }

  /// Converts this object into a JSON formatted object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'label': label,
      'extensions': extensions,
      'mimeTypes': mimeTypes,
      'macUTIs': macUTIs,
      'webWildCards': webWildCards,
    };
  }

  /// True if this type group should allow any file.
  bool get allowsAny {
    return (extensions?.isEmpty ?? true) &&
        (mimeTypes?.isEmpty ?? true) &&
        (macUTIs?.isEmpty ?? true) &&
        (webWildCards?.isEmpty ?? true);
  }

  /// Returns the list of uniform type identifiers for this group
  List<String>? get macUTIs => uniformTypeIdentifiers;

  static List<String>? _removeLeadingDots(List<String>? exts) => exts
      ?.map((String ext) => ext.startsWith('.') ? ext.substring(1) : ext)
      .toList();
}
