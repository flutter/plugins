// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A set of allowed XTypes
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  ///
  /// A group with none of the type options provided indicates that any type is
  /// allowed.
  XTypeGroup({
    this.label,
    List<String>? extensions,
    this.mimeTypes,
    this.macUTIs,
    this.webWildCards,
  }) : this.extensions = _removeLeadingDots(extensions);

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

  static List<String>? _removeLeadingDots(List<String>? exts) =>
      exts?.map((ext) => ext.startsWith('.') ? ext.substring(1) : ext).toList();
}
