// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library ios_camera;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'src/common/camera_abstraction.dart';
import 'src/common/camera_channel.dart';
import 'src/common/camera_mixins.dart';
import 'src/common/native_texture.dart';

part 'src/ios/capture_discovery_session.dart';
part 'src/ios/capture_device.dart';
part 'src/ios/capture_input.dart';
part 'src/ios/capture_output.dart';
part 'src/ios/capture_session.dart';
