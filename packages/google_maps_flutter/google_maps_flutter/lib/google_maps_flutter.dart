// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_maps_flutter;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// TODO: Remove this import after e2e tests have been migrated.
import 'package:google_maps_flutter_platform_interface/src/method_channel/method_channel_google_maps_flutter.dart';

export 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
  show LatLng, LatLngBounds, MapType, CameraTargetBounds, MinMaxZoomPreference, MapStyleException;

part 'src/bitmap.dart';
part 'src/callbacks.dart';
part 'src/camera.dart';
part 'src/cap.dart';
part 'src/circle.dart';
part 'src/circle_updates.dart';
part 'src/controller.dart';
part 'src/google_map.dart';
part 'src/joint_type.dart';
part 'src/marker.dart';
part 'src/marker_updates.dart';
part 'src/pattern_item.dart';
part 'src/polygon.dart';
part 'src/polygon_updates.dart';
part 'src/polyline.dart';
part 'src/polyline_updates.dart';
part 'src/screen_coordinate.dart';
