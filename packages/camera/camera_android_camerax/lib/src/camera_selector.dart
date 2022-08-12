// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'instance_manager.dart';
import 'java_object.dart';

class CameraSelector extends JavaObject {
  CameraSelector({int? lensFacing}) : super.detached() {
    _api.create(this, lensFacing);
  }

  CameraSelector.detached():
      : super.detached();
    
  static CameraSelectorHostApiImpl _api = CameraSelectorHostApiImpl();

  final static Builder defaultFrontCamera = 
    Builder()
      .requireLensFacing(LENS_FACING_FRONT)
        .build();

  final static Builder defaultBackCamera = 
    Builder()
      .requireLensFacing(LENS_FACING_Back)
        .build();

  /// Filters available cameras based on provided [CameraInfo]s.
  List<CameraInfo> filter(List<CameraInfo> cameraInfos) => _api.filter(cameraInfos);

  /// Builds a [CameraSelector].
  class Builder {
    CameraSelector build() {
        //TODO(cs): can I refactor this? I feel like I'm copying native impl.
    }

    Builder requireLensFacing(int lensFacing) {
        //TODO(cs): can I refactor this? I feel like I'm copying native impl.
    }
  }
}
