// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The type of the retrieved data in a [LostDataResponse].
enum RetrieveType {
  /// A static picture. See [ImagePicker.pickImage].
  image,

  /// A video. See [ImagePicker.pickVideo].
  video
}
