// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

import 'page.dart';

class MoveCameraPage extends Page {
  MoveCameraPage() : super("MOVE");

  final GoogleMapsOverlayController controller =
      new GoogleMapsOverlayController.fromSize(300.0, 200.0);

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
            new Column(
              children: <Widget>[
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          bearing: 270.0,
                          target: const LatLng(51.5160895, -0.1294527),
                          tilt: 30.0,
                          zoom: 17.0,
                        ),
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                  child: const Text('newCameraPosition'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.newLatLng(
                        const LatLng(56.1725505, 10.1850512),
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                  child: const Text('newLatLng'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.newLatLngBounds(
                        const LatLngBounds(
                          southwest: const LatLng(-38.483935, 113.248673),
                          northeast: const LatLng(-8.982446, 153.823821),
                        ),
                        10.0,
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                  child: const Text('newLatLngBounds'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.newLatLngZoom(
                        const LatLng(37.4231613, -122.087159),
                        11.0,
                      ),
                    );
                  },
                  color: Colors.lightBlue,
                  child: const Text('newLatLngZoom'),
                ),
              ],
            ),
            new Column(
              children: <Widget>[
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.scrollBy(150.0, -225.0),
                    );
                  },
                  color: Colors.red,
                  child: const Text('scrollBy'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.zoomBy(
                        -0.5,
                        const Offset(30.0, 20.0),
                      ),
                    );
                  },
                  color: Colors.yellow,
                  child: const Text('zoomBy with focus'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.zoomBy(0.7),
                    );
                  },
                  color: Colors.yellow,
                  child: const Text('zoomBy'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.zoomIn(),
                    );
                  },
                  color: Colors.yellow,
                  child: const Text('zoomIn'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.zoomOut(),
                    );
                  },
                  color: Colors.yellow,
                  child: const Text('zoomOut'),
                ),
                new FlatButton(
                  onPressed: () {
                    controller.mapsController.moveCamera(
                      CameraUpdate.zoomTo(16.0),
                    );
                  },
                  color: Colors.yellow,
                  child: const Text('zoomTo'),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
