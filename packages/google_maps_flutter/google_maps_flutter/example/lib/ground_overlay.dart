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
  GroundOverlay? _groundOverlay;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeGroundOverlay() {
    setState(() {
      _groundOverlay = null;
    });
  }

  void _addGroundOverlay() {
    final GroundOverlay groundOverlay = GroundOverlay(
      groundOverlayId: GroundOverlayId('ground_overlay_1'),
      image: BitmapDescriptor.defaultMarker,
      position: LatLng(59.935460, 30.325177),
      width: 100,
    );
    setState(() {
      _groundOverlay = groundOverlay;
    });
  }

  @override
  Widget build(BuildContext context) {
    Set<GroundOverlay> overlays = <GroundOverlay>{
      if (_groundOverlay != null) _groundOverlay!,
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
                zoom: 7.0,
              ),
              groundOverlays: overlays,
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        TextButton(
          child: const Text('Add ground overlay'),
          onPressed: _addGroundOverlay,
        ),
        TextButton(
          child: const Text('Remove ground overlay'),
          onPressed: _removeGroundOverlay,
        ),
      ],
    );
  }
}
