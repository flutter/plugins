// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A set of allowed XTypes
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  XTypeGroup({
    this.label,
    this.extensions,
    this.mimeTypes,
    this.macUTIs,
    this.webWildCards,
  }) : assert(
            !((extensions == null || extensions.isEmpty) &&
                (mimeTypes == null || mimeTypes.isEmpty) &&
                (macUTIs == null || macUTIs.isEmpty) &&
                (webWildCards == null || webWildCards.isEmpty)),
            "At least one type must be provided for an XTypeGroup.");

  /// The 'name' or reference to this group of types
  final String label;

  /// The extensions for this group
  final List<String> extensions;

  /// The MIME types for this group
  final List<String> mimeTypes;

  /// The UTIs for this group
  final List<String> macUTIs;

  /// The web wild cards for this group (ex: image/*, video/*)
  final List<String> webWildCards;

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
