// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/page.dart';

class MapDataUiPage extends Page {
  MapDataUiPage() : super(const Icon(Icons.map), 'Map data');

  @override
  Widget build(BuildContext context) {
    return const MapDataUiBody();
  }
}

class MapDataUiBody extends StatefulWidget {
  const MapDataUiBody();

  @override
  State<StatefulWidget> createState() => MapDataUiBodyState();
}

class MapDataUiBodyState extends State<MapDataUiBody> {
  MapDataUiBodyState();

  static final CameraPosition _kInitialPosition = const CameraPosition(
    target: LatLng(-33.852, 151.211),
    zoom: 11.0,
  );

  GoogleMapController mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
      southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: _kInitialPosition,
    );

    final List<Widget> columnChildren = <Widget>[
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
    ];

    if (mapController != null) {
      columnChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              Text(
                  'VisibleRegion: \nnortheast: ${_visibleRegion.northeast},\nsouthwest: ${_visibleRegion.southwest}'),
              _getVisibleRegionButton(),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  Widget _getVisibleRegionButton() {
    return FlatButton(
      child: const Text('get VisibleRegion'),
      onPressed: () async {
        final LatLngBounds visibleRegion =
            await mapController.getVisibleRegion();

        setState(() {
          _visibleRegion = visibleRegion;
        });
      },
    );
  }
}
