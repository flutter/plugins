// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceGroundOverlayPage extends GoogleMapExampleAppPage {
  PlaceGroundOverlayPage() : super(const Icon(Icons.image), 'Place image');

  @override
  Widget build(BuildContext context) {
    return const PlaceGroundOverlayBody();
  }
}

class PlaceGroundOverlayBody extends StatefulWidget {
  const PlaceGroundOverlayBody();

  @override
  State<StatefulWidget> createState() => PlaceGroundOverlayBodyState();
}

class PlaceGroundOverlayBodyState extends State<PlaceGroundOverlayBody> {
  PlaceGroundOverlayBodyState();

  BitmapDescriptor _bitMapDesc;
  GoogleMapController controller;
  Map<GroundOverlayId, GroundOverlay> groundOverlays =
      <GroundOverlayId, GroundOverlay>{};
  int _groundOverlayIdCounter = 0;
  GroundOverlayId selectedGroundOverlay;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onGroundOverlayTapped(GroundOverlayId groundOverlayId) {
    setState(() {
      selectedGroundOverlay = groundOverlayId;
    });
  }

  Future<void> _createGroundOverlayImageFromAsset(BuildContext context) async {
    if (_bitMapDesc == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: Size.square(48));
      await BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        'assets/red_square.png',
      ).then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _bitMapDesc = bitmap;
    });
  }

  void _remove() {
    setState(() {
      if (groundOverlays.containsKey(selectedGroundOverlay)) {
        groundOverlays.remove(selectedGroundOverlay);
      }
      selectedGroundOverlay = null;
    });
  }

  void _add() {
    final double offset = _groundOverlayIdCounter.ceilToDouble() / 1000;
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(-33.853432 + offset, 151.211807),
      northeast: LatLng(-33.851327 + offset, 151.213880),
    );
    final int groundOverlayCount = groundOverlays.length;

    if (groundOverlayCount == 12) {
      return;
    }

    final String groundOverlayIdVal =
        'ground_overlay_id_$_groundOverlayIdCounter';
    _groundOverlayIdCounter++;
    final GroundOverlayId groundOverlayId = GroundOverlayId(groundOverlayIdVal);

    final GroundOverlay groundOverlay = GroundOverlay.fromBounds(
      bounds,
      groundOverlayId: groundOverlayId,
      bitmap: _bitMapDesc,
      consumeTapEvents: true,
      onTap: () {
        _onGroundOverlayTapped(groundOverlayId);
      },
    );

    setState(() {
      groundOverlays[groundOverlayId] = groundOverlay;
    });
  }

  Future<void> _changeTransparency() async {
    final GroundOverlay groundOverlay = groundOverlays[selectedGroundOverlay];
    final double current = groundOverlay.opacity;
    setState(() {
      groundOverlays[selectedGroundOverlay] = groundOverlay.copyWith(
        opacityParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _changeBearing() async {
    final GroundOverlay groundOverlay = groundOverlays[selectedGroundOverlay];
    final double current = groundOverlay.bearing ?? 0.0;
    setState(() {
      groundOverlays[selectedGroundOverlay] = groundOverlay.copyWith(
        bearingParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }

  void _toggleVisible() {
    final GroundOverlay groundOverlay = groundOverlays[selectedGroundOverlay];
    setState(() {
      groundOverlays[selectedGroundOverlay] = groundOverlay.copyWith(
        visibleParam: !groundOverlay.visible,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    _createGroundOverlayImageFromAsset(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 300.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 15.0,
              ),
              groundOverlays: groundOverlays.values.toSet(),
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add'),
                          onPressed: _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed:
                              (selectedGroundOverlay == null) ? null : _remove,
                        ),
                        TextButton(
                          child: const Text('change transparency'),
                          onPressed: (selectedGroundOverlay == null)
                              ? null
                              : _changeTransparency,
                        ),
                        TextButton(
                          child: const Text('change bearing'),
                          onPressed: (selectedGroundOverlay == null)
                              ? null
                              : _changeBearing,
                        ),
                        TextButton(
                          child: const Text('toggle visible'),
                          onPressed: (selectedGroundOverlay == null)
                              ? null
                              : _toggleVisible,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
