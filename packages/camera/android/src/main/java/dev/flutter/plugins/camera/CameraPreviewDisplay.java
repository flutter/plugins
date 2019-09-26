// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import androidx.annotation.NonNull;

public interface CameraPreviewDisplay {
  void startStreaming(@NonNull final ImageStreamConnection connection);

  interface ImageStreamConnection {
    void onConnectionReady(@NonNull CameraImageStream stream);

    void onConnectionClosed();
  }
}
