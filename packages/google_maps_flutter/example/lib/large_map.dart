// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class LargeMapPage extends Page {
  LargeMapPage() : super(const Icon(Icons.map), 'Large map');

  @override
  final GoogleMapOverlayController controller =
      GoogleMapOverlayController.fromSize(width: 300.0, height: 500.0);

  @override
  Widget build(BuildContext context) {
    return Center(child: GoogleMapOverlay(controller: controller));
  }
}
