// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit
import ios_platform_images

func MakeImage() -> UIImageView {
  let image = UIImage.flutterImage(withName: "assets/foo.png")
  return UIImageView(image: image)
}
