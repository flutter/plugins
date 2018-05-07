// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

const LatLngBounds sydneyBounds = const LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

class MapUiPage extends Page {
  MapUiPage() : super(const Icon(Icons.map), "User interface");

  @override
  final GoogleMapOverlayController controller =
      new GoogleMapOverlayController.fromSize(
    width: 300.0,
    height: 200.0,
    options: const GoogleMapOptions(
      cameraPosition: const CameraPosition(
        target: const LatLng(-33.852, 151.211),
        zoom: 11.0,
      ),
      trackCameraPosition: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return new MapUiBody(controller);
  }
}

class MapUiBody extends StatefulWidget {
  final GoogleMapOverlayController controller;

  const MapUiBody(this.controller);

  @override
  State<StatefulWidget> createState() => new MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  CameraPosition _position;
  GoogleMapOptions _options;
  bool _isMoving;

  @override
  void initState() {
    super.initState();
    final GoogleMapController mapController = widget.controller.mapController;
    mapController.addListener(() {
      setState(() {
        _options = mapController.options;
        _position = mapController.cameraPosition;
        _isMoving = mapController.isCameraMoving;
      });
    });
    _options = mapController.options;
    _position = mapController.cameraPosition;
    _isMoving = mapController.isCameraMoving;
  }

  Widget _compassToggler() {
    return new FlatButton(
      child:
          new Text('${_options.compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(compassEnabled: !_options.compassEnabled),
        );
      },
    );
  }

  Widget _latLngBoundsToggler() {
    return new FlatButton(
      child: new Text(
        _options.cameraTargetBounds.bounds == null
            ? 'bound camera target'
            : 'release camera target',
      ),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
            cameraTargetBounds: _options.cameraTargetBounds.bounds == null
                ? const CameraTargetBounds(sydneyBounds)
                : CameraTargetBounds.unbounded,
          ),
        );
      },
    );
  }

  Widget _zoomBoundsToggler() {
    return new FlatButton(
      child: new Text(_options.minMaxZoomPreference.minZoom == null
          ? 'bound zoom'
          : 'release zoom'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
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
    return new FlatButton(
      child: new Text('change map type to $nextType'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(mapType: nextType),
        );
      },
    );
  }

  Widget _rotateToggler() {
    return new FlatButton(
      child: new Text(
          '${_options.rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
            rotateGesturesEnabled: !_options.rotateGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _scrollToggler() {
    return new FlatButton(
      child: new Text(
          '${_options.scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
            scrollGesturesEnabled: !_options.scrollGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _tiltToggler() {
    return new FlatButton(
      child: new Text(
          '${_options.tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
            tiltGesturesEnabled: !_options.tiltGesturesEnabled,
          ),
        );
      },
    );
  }

  Widget _zoomToggler() {
    return new FlatButton(
      child: new Text(
          '${_options.zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        widget.controller.mapController.updateMapOptions(
          new GoogleMapOptions(
            zoomGesturesEnabled: !_options.zoomGesturesEnabled,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Center(
            child: new GoogleMapOverlay(controller: widget.controller),
          ),
        ),
        new Column(
          children: <Widget>[
            new Text('camera bearing: ${_position.bearing}'),
            new Text(
                'camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                '${_position.target.longitude.toStringAsFixed(4)}'),
            new Text('camera zoom: ${_position.zoom}'),
            new Text('camera tilt: ${_position.tilt}'),
            new Text(_isMoving ? '(Camera moving)' : '(Camera idle)'),
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
