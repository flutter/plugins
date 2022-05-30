// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

/// The type of media to allow the user to select with [ImagePickerPlatform.getMedia].
enum MediaSelectionType {
  /// Static pictures.
  image,

  /// Videos.
  video,
}

/// Serializes a [MediaSelectionType] value into a String value.
String serializeMediaSelectionType(MediaSelectionType type) {
  switch (type) {
    case MediaSelectionType.image:
      return 'image';
    case MediaSelectionType.video:
      return 'video';
    default:
      throw UnimplementedError(
          'No serialized value has yet been implemented for MediaSelectionType "$type"');
  }
}
