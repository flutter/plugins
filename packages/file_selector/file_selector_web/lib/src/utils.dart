// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// Convert list of XTypeGroups to a comma-separated string
String acceptedTypesToString(List<XTypeGroup>? acceptedTypes) {
  if (acceptedTypes == null) {
    return '';
  }
  final List<String> allTypes = <String>[];
  for (final XTypeGroup group in acceptedTypes) {
    // If any group allows everything, no filtering should be done.
    if (group.allowsAny) {
      return '';
    }
    _validateTypeGroup(group);
    if (group.extensions != null) {
      allTypes.addAll(group.extensions!.map(_normalizeExtension));
    }
    if (group.mimeTypes != null) {
      allTypes.addAll(group.mimeTypes!);
    }
    if (group.webWildCards != null) {
      allTypes.addAll(group.webWildCards!);
    }
  }
  return allTypes.join(',');
}

/// Make sure that at least one of the supported fields is populated.
void _validateTypeGroup(XTypeGroup group) {
  if ((group.extensions?.isEmpty ?? true) &&
      (group.mimeTypes?.isEmpty ?? true) &&
      (group.webWildCards?.isEmpty ?? true)) {
    throw ArgumentError('Provided type group $group does not allow '
        'all files, but does not set any of the web-supported filter '
        'categories. At least one of "extensions", "mimeTypes", or '
        '"webWildCards" must be non-empty for web if anything is '
        'non-empty.');
  }
}

/// Append a dot at the beggining if it is not there png -> .png
String _normalizeExtension(String ext) {
  return ext.isNotEmpty && ext[0] != '.' ? '.$ext' : ext;
}
