// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library android_camera;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'src/common/camera_abstraction.dart';
import 'src/common/camera_channel.dart';
import 'src/common/camera_mixins.dart';
import 'src/common/native_texture.dart';

part 'src/android/camera_characteristics.dart';
part 'src/android/camera_device.dart';
part 'src/android/camera_manager.dart';
part 'src/android/capture_request.dart';
part 'src/android/camera_capture_session.dart';
part 'src/android/surface.dart';
