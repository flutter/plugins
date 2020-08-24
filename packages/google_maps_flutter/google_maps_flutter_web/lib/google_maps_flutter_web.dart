// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library google_maps_flutter_web;

import 'dart:async';
import 'dart:html';
import 'dart:ui' as ui;
import 'dart:convert';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import 'package:sanitize_html/sanitize_html.dart';

import 'package:stream_transform/stream_transform.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_maps/google_maps.dart' as gmaps;

import 'src/types.dart';

part 'src/google_maps_flutter_web.dart';
part 'src/google_maps_controller.dart';
part 'src/circle.dart';
part 'src/circles.dart';
part 'src/polygon.dart';
part 'src/polygons.dart';
part 'src/polyline.dart';
part 'src/polylines.dart';
part 'src/marker.dart';
part 'src/markers.dart';
part 'src/convert.dart';
