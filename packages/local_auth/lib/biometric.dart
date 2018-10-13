// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

enum Biometric {
  /// On iOS, this represents FaceID support.  On Android, this currently will not be returned.
  face,

  /// On iOS and Android, this represents Fingerprint scanner support.
  fingerprint,
}
