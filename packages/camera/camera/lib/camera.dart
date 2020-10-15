// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:camera_platform_interface/camera_platform_interface.dart';

/// Completes with a list of available cameras.
///
/// May throw a [CameraException].
Future<List<CameraDescription>> availableCameras() async =>
    CameraPlatform.instance.availableCameras();

