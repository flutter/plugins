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
  final GoogleMapOverlayController controller =
      GoogleMapOverlayController.fromSize(
    width: 300.0,
    height: 200.0,
    options: GoogleMapOptions(
      cameraPosition: const CameraPosition(
        target: LatLng(-33.852, 151.211),
        zoom: 11.0,
      ),
      trackCameraPosition: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MapUiBody(controller);
  }
}

class MapUiBody extends StatefulWidget {
  final GoogleMapOverlayController controller;

  const MapUiBody(this.controller);

  @override
  State<StatefulWidget> createState() =>
      MapUiBodyState(controller.mapController);
}

class MapUiBodyState extends State<MapUiBody> {
  MapUiBodyState(this.mapController);

  final GoogleMapController mapController;
  CameraPosition _position;
  GoogleMapOptions _options;
  bool _isMoving;

  @override
  void initState() {
    super.initState();
    mapController.addListener(_onMapChanged);
    _extractMapInfo();
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

  Widget _compassToggler() {
    return FlatButton(
      child: Text('${_options.compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(compassEnabled: !_options.compassEnabled),
        );
      },
    );
  }

  Widget _latLngBoundsToggler() {
    return FlatButton(
      child: Text(
        _options.cameraTargetBounds.bounds == null
            ? 'bound camera target'
            : 'release camera target',
      ),
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
    return FlatButton(
      child: Text(_options.minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
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
    return FlatButton(
      child: Text('change map type to $nextType'),
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(mapType: nextType),
        );
      },
    );
  }

  Widget _rotateToggler() {
    return FlatButton(
      child: Text(
          '${_options.rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
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
    return FlatButton(
      child: Text(
          '${_options.scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
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
    return FlatButton(
      child:
          Text('${_options.tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
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
    return FlatButton(
      child:
          Text('${_options.zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        mapController.updateMapOptions(
          GoogleMapOptions(
            zoomGesturesEnabled: !_options.zoomGesturesEnabled,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: GoogleMapOverlay(controller: widget.controller),
          ),
        ),
        Column(
          children: <Widget>[
            Text('camera bearing: ${_position.bearing}'),
            Text('camera target: ${_position.target.latitude
                    .toStringAsFixed(4)},'
                '${_position.target.longitude.toStringAsFixed(4)}'),
            Text('camera zoom: ${_position.zoom}'),
            Text('camera tilt: ${_position.tilt}'),
            Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
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
      ],
    );
  }
}
