// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super("MARK");

  final GoogleMapsOverlayController controller =
      new GoogleMapsOverlayController.fromSize(200.0, 300.0)
        ..mapsController.moveCamera(CameraUpdate.newLatLngZoom(
          const LatLng(-33.852, 151.211),
          11.0,
        ));

  @override
  PlatformOverlayController get overlayController =>
      controller.overlayController;

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Center(child: new GoogleMapsOverlay(controller: controller)),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new FlatButton(
              onPressed: () {
                controller.mapsController.addMarker(
                  const MarkerOptions(
                    position: const LatLng(-33.86711, 151.1947171),
                  ),
                );
              },
              color: Colors.blue,
              child: const Text('Default'),
            ),
          ],
        )
      ],
    );
  }
}
