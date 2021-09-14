// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

/// A page to demonstrate adding ground overlays.
class GroundOverlayPage extends GoogleMapExampleAppPage {
  GroundOverlayPage() : super(const Icon(Icons.map), 'Ground overlay');

  @override
  Widget build(BuildContext context) {
    return const GroundOverlayBody();
  }
}

class GroundOverlayBody extends StatefulWidget {
  const GroundOverlayBody();

  @override
  State<StatefulWidget> createState() => GroundOverlayBodyState();
}

class GroundOverlayBodyState extends State<GroundOverlayBody> {
  GroundOverlayBodyState();

  GoogleMapController? controller;
  BitmapDescriptor? _overlayImage;
  double _bearing = 0;
  double _transparency = 0;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeGroundOverlay() {
    setState(() {
      _overlayImage = null;
    });
  }

  void _addGroundOverlay() {
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/red_square.png',
    ).then((BitmapDescriptor bitmap) {
      setState(() {
        _overlayImage = bitmap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<GroundOverlay> overlays = <GroundOverlay>{
      if (_overlayImage != null)
        GroundOverlay(
          groundOverlayId: GroundOverlayId('ground_overlay_1'),
          image: _overlayImage!,
          position: LatLng(59.935460, 30.325177),
          width: 200,
          bearing: _bearing,
          transparency: _transparency,
        ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 300.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(59.935460, 30.325177),
                zoom: 15.0,
              ),
              groundOverlays: overlays,
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        ...[
          if (overlays.isEmpty)
            TextButton(
              child: const Text('Add ground overlay'),
              onPressed: _addGroundOverlay,
            ),
          if (overlays.isNotEmpty)
            TextButton(
              child: const Text('Remove ground overlay'),
              onPressed: _removeGroundOverlay,
            ),
          if (overlays.isNotEmpty)
            Padding(padding: EdgeInsets.all(8), child: const Text('Bearing')),
          if (overlays.isNotEmpty)
            Slider(
              label: "Bearing",
              value: _bearing,
              min: 0,
              max: 360,
              onChanged: (double value) {
                setState(() {
                  _bearing = value;
                });
              },
            ),
          if (overlays.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(8),
              child: const Text('Transparency'),
            ),
          if (overlays.isNotEmpty)
            Slider(
              label: "Transparency",
              value: _transparency * 100,
              min: 0,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _transparency = value / 100.0;
                });
              },
            ),
        ],
      ],
    );
  }
}
