// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

final LatLngBounds sydneyBounds = LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

class MapUiPage extends Page {
  MapUiPage() : super(const Icon(Icons.map), 'User interface');

  @override
  Widget build(BuildContext context) {
    return const MapUiBody();
  }
}

class MapUiBody extends StatefulWidget {
  const MapUiBody();

  @override
  State<StatefulWidget> createState() => MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState();

  GoogleMapController mapController;
  CameraPosition _position;
  GoogleMapOptions _options = GoogleMapOptions(
    cameraPosition: const CameraPosition(
      target: LatLng(-33.852, 151.211),
      zoom: 11.0,
    ),
    trackCameraPosition: true,
    compassEnabled: true,
  );
  bool _isMoving = false;

  @override
  void initState() {
    super.initState();
  }

  void _onMapChanged() {
    setState(() {
      _extractMapInfo();
    });
  }

  void _extractMapInfo() {
    _options = mapController.options;
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  @override
  void dispose() {
    mapController.removeListener(_onMapChanged);
    super.dispose();
  }

  Widget _button({@required String text, @required VoidCallback onPressed}) {
    return Container(
      height: 48.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
      child: RaisedButton(
        color: Colors.lightBlue[700],
        textColor: Colors.white,
        child: Text(
          text,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _compassToggler() {
    return _button(
      text: '${_options.compassEnabled ? 'Disable' : 'Enable'} Compass',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(compassEnabled: !_options.compassEnabled),
        );
      },
    );
  }

  Widget _latLngBoundsToggler() {
    return _button(
      text: _options.cameraTargetBounds.bounds == null
            ? 'Bound Camera Target'
            : 'Release Camera Target',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            cameraTargetBounds: _options.cameraTargetBounds.bounds == null
                ? CameraTargetBounds(sydneyBounds)
                : CameraTargetBounds.unbounded,
          ),
        );
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return _button(
      text: _options.minMaxZoomPreference.minZoom == null
            ? 'Bound Zoom'
            : 'Release Zoom',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            minMaxZoomPreference: _options.minMaxZoomPreference.minZoom == null
                ? const MinMaxZoomPreference(12.0, 16.0)
                : MinMaxZoomPreference.unbounded,
          ),
        );
      },
    );
  }

  Widget _mapTypeCycler() {
    final MapType nextType =
        MapType.values[(_options.mapType.index + 1) % MapType.values.length];
    return _button(
      text: 'Change map type to $nextType',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(mapType: nextType),
        );
      },
    );
  }

  Widget _rotateToggler() {
    return _button(
      text: '${_options.rotateGesturesEnabled ? 'Disable' : 'Enable'} Rotate',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            rotateGesturesEnabled: !_options.rotateGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _scrollToggler() {
    return _button(
      text: '${_options.scrollGesturesEnabled ? 'Disable' : 'Enable'} Scroll',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            scrollGesturesEnabled: !_options.scrollGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _tiltToggler() {
    return _button(
      text: '${_options.tiltGesturesEnabled ? 'Disable' : 'Enable'} Tilt',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            tiltGesturesEnabled: !_options.tiltGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _zoomToggler() {
    return _button(
      text: '${_options.zoomGesturesEnabled ? 'Disable' : 'Enable'} Zoom',
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            zoomGesturesEnabled: !_options.zoomGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _currentCompassDetails() {
    var currentCameraDetailsTextStyle = TextStyle(
      color: Colors.red[900],
      fontSize: 14.0,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 12.0),
      child: Column(
        children: <Widget>[
          Text('Camera Bearing: ${_position.bearing}',
              style: currentCameraDetailsTextStyle),
          Text(
            'Camera Target: ${_position.target.latitude.toStringAsFixed(4)},'
                '${_position.target.longitude.toStringAsFixed(4)}',
            style: currentCameraDetailsTextStyle,
          ),
          Text('Camera Zoom: ${_position.zoom}',
              style: currentCameraDetailsTextStyle),
          Text('Camera Tilt: ${_position.tilt}',
              style: currentCameraDetailsTextStyle),
          Text(_isMoving ? '(Camera Moving)' : '(Camera Idle)',
              style: currentCameraDetailsTextStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: GoogleMap(
              onMapCreated: onMapCreated,
              options: GoogleMapOptions(
                cameraPosition: const CameraPosition(
                  target: LatLng(-33.852, 151.211),
                  zoom: 11.0,
                ),
                trackCameraPosition: true,
              ),
            ),
          ),
        ),
      ),
    ];

    if (mapController != null) {
      columnChildren.add(_currentCompassDetails());
      columnChildren.add(
        Expanded(
          child: ListView(
            children: <Widget>[
              _compassToggler(),
              _latLngBoundsToggler(),
              _mapTypeCycler(),
              _zoomBoundsToggler(),
              _rotateToggler(),
              _scrollToggler(),
              _tiltToggler(),
              _zoomToggler(),
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
    mapController = controller;
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
    setState(() {});
  }
}
