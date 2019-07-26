// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

const CameraPosition _kInitialPosition = CameraPosition(target: LatLng(-33.852, 151.211), zoom: 11.0);

class MapCoordinatesPage extends Page {
  MapCoordinatesPage() : super(const Icon(Icons.map), 'Map coordinates');
  
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
  
  GoogleMapController mapController;
  LatLngBounds _visibleRegion = LatLngBounds(
    southwest: const LatLng(0, 0),
    northeast: const LatLng(0, 0),
  );
  
  bool _pointInitialized = false;
  LatLng _latLng = const LatLng(0, 0);
  Point _point = const Point(x: 0, y: 0);
  
  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: onMapCreated,
      onTap: _displayTapCoordinates,
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
      final String currentVisibleRegion = 'VisibleRegion:'
          '\nnortheast: ${_visibleRegion.northeast},'
          '\nsouthwest: ${_visibleRegion.southwest}';
      columnChildren.add(Center(child: Text(currentVisibleRegion)));
      columnChildren.add(_getVisibleRegionButton());
      final String currentClickedPoint = 'Click on map to get screen coords:'
          '\nx: ${_point.x},'
          '\ny: ${_point.y}';
      columnChildren.add(Center(child: Text(currentClickedPoint)));
      columnChildren.add(_getCoordinateOfClick());
      columnChildren.add(Center(
          child: Text("Lat/Lng of point on screen"
              "\nlat: ${_latLng.latitude}"
              "\nlng: ${_latLng.longitude}")));
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }
  
  void onMapCreated(GoogleMapController controller) async {
    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    setState(() {
      mapController = controller;
      _visibleRegion = visibleRegion;
    });
  }
  
  void _displayTapCoordinates(LatLng latLng) async {
    final Point screenPoint = await mapController.toScreenLocation(latLng);
    setState(() {
      _pointInitialized = true;
      _point = screenPoint;
    });
  }
  
  Widget _getVisibleRegionButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        child: const Text('Get Visible Region'),
        onPressed: () async {
          final LatLngBounds visibleRegion = await mapController.getVisibleRegion();
          setState(() {
            _visibleRegion = visibleRegion;
          });
        },
      ),
    );
  }
  
  Widget _getCoordinateOfClick() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        child: const Text('Get Coordinates of click'),
        onPressed: () async {
          if (!_pointInitialized) {
            Scaffold.of(context).showSnackBar(
                SnackBar(content: Text("Please click on the map first")));
          }
          final LatLng latLng = await mapController.fromScreenLocation(_point);
          setState(() {
            _latLng = latLng;
          });
        },
      ),
    );
  }
}
