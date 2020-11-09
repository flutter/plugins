// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'types.dart';

/// Signature for a callback receiving the a camera image.
///
/// This is used by [CameraPlatform.startImageStream].
// ignore: inference_failure_on_function_return_type
typedef ImageAvailableHandler = Function(CameraImage image);
