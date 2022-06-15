// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The type of the retrieved data in a [LostDataResponse].
enum RetrieveType {
  /// A static picture. See [ImagePicker.pickImage].
  image,

  /// A video. See [ImagePicker.pickVideo].
  video
}

/// Serializes the value of the [RetrieveType] enum.
String serializeRetrieveType(RetrieveType type) {
  switch (type) {
    case RetrieveType.image:
      return 'image';
    case RetrieveType.video:
      return 'video';
  }
}
