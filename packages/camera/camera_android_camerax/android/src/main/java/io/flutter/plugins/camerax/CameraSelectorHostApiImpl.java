// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

public class CameraSelectorHostApiImpl {
  public CameraSelectorHostApiImpl() {
    cameraSelector = new CameraSelector.Builder().build();
  }

  CameraSelector cameraSelector;

  // Filters available cameras based on the cameraInfos provided.
  @override
  List<CameraInfo> filter(long instance, List<int> cameraInfos) {
    List<CameraInfo> cameraInfos = cameraSelctor.filter(cameraInfos);
    return cameraInfos;
  }
}
