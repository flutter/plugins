// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';

const CameraPosition _kInitialPosition =
    CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11.0);

class MapCoordinatesPage extends GoogleMapExampleAppPage {
  const MapCoordinatesPage({Key? key})
      : super(const Icon(Icons.map), 'Map coordinates', key: key);

  @override
  Widget build(BuildContext context) {
    return const _MapCoordinatesBody();
  }
}

class _MapCoordinatesBody extends StatefulWidget {
  const _MapCoordinatesBody();

  @override
  State<StatefulWidget> createState() => _MapCoordinatesBodyState();
}

class _MapCoordinatesBodyState extends State<_MapCoordinatesBody> {
  _MapCoordinatesBodyState();

  ExampleGoogleMapController? mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );

  @override
  Widget build(BuildContext context) {
    final ExampleGoogleMap googleMap = ExampleGoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
      onCameraIdle:
          _updateVisibleRegion, // https://github.com/flutter/flutter/issues/54758
    );

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollState) {
        _updateVisibleRegion();
        return true;
      },
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 200.0,
                    child: googleMap,
                  ),
                ),
              ),
              // Add a block at the bottom of this list to allow validation that the visible region of the map
              // does not change when scrolled under the safe view on iOS.
              // https://github.com/flutter/flutter/issues/107913
              const SizedBox(
                width: 300,
                height: 1000,
              ),
            ],
          ),
          if (mapController != null)
            Center(
              child: Text('VisibleRegion:'
                  '\nnortheast: ${_visibleRegion.northeast},'
                  '\nsouthwest: ${_visibleRegion.southwest}'),
            ),
        ],
      ),
    );
  }

  Future<void> onMapCreated(ExampleGoogleMapController controller) async {
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    setState(() {
      mapController = controller;
      _visibleRegion = visibleRegion;
    });
  }

  Future<void> _updateVisibleRegion() async {
    final LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
    setState(() {
      _visibleRegion = visibleRegion;
    });
  }
}
