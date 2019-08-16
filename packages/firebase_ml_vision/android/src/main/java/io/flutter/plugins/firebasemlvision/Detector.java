// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;

public interface Detector {
  void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result);

  void close() throws IOException;
}
