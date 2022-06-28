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
