// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

import 'page.dart';

const LatLngBounds sydneyBounds = const LatLngBounds(
  southwest: const LatLng(-34.022631, 150.620685),
  northeast: const LatLng(-33.571835, 151.325952),
);

class MapUiPage extends Page {
  MapUiPage() : super(const Icon(Icons.map), "User interface");

  final GoogleMapOverlayController controller =
      new GoogleMapOverlayController.fromSize(
    width: 300.0,
    height: 200.0,
    options: const GoogleMapOptions(
      cameraMoveEvents: const CameraMoveEvents(onCameraMoved: true),
      cameraPosition: const CameraPosition(
        target: const LatLng(-33.852, 151.211),
        zoom: 11.0,
      ),
    ),
  );

  @override
  PlatformOverlayController get overlayController =>
      controller.overlayController;

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

  @override
  void initState() {
    super.initState();
    widget.controller.mapsController.onCameraMove = (CameraPosition position) {
      setState(() {
        _position = position;
      });
    };
    _position = widget.controller.mapsController.options.cameraPosition;
  }

  Widget _compassToggler(GoogleMapOptions options) {
    return new FlatButton(
      child:
          new Text('${options.compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(compassEnabled: !options.compassEnabled),
        );
        _reloadOptions();
      },
    );
  }

  Widget _latLngBoundsToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
        options.latLngCameraTargetBounds.bounds == null
            ? 'bound camera target'
            : 'release camera target',
      ),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            latLngCameraTargetBounds: options.latLngCameraTargetBounds.bounds == null
                ? const LatLngCameraTargetBounds(sydneyBounds)
                : LatLngCameraTargetBounds.unbounded,
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _zoomBoundsToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          options.minMaxZoomPreference.minZoom == null ? 'bound zoom' : 'release zoom'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            minMaxZoomPreference: options.minMaxZoomPreference.minZoom == null
                ? const MinMaxZoomPreference(12.0, 16.0)
                : MinMaxZoomPreference.unbounded,
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _mapTypeCycler(GoogleMapOptions options) {
    final MapType nextType =
        MapType.values[(options.mapType.index + 1) % MapType.values.length];
    return new FlatButton(
      child: new Text('change map type to $nextType'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(mapType: nextType),
        );
        _reloadOptions();
      },
    );
  }

  Widget _rotateToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          '${options.rotateGesturesEnabled ? 'disable' : 'enable'} rotate'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            rotateGesturesEnabled: !options.rotateGesturesEnabled,
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _scrollToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          '${options.scrollGesturesEnabled ? 'disable' : 'enable'} scroll'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            scrollGesturesEnabled: !options.scrollGesturesEnabled,
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _tiltToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          '${options.tiltGesturesEnabled ? 'disable' : 'enable'} tilt'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            tiltGesturesEnabled: !options.tiltGesturesEnabled,
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _zoomToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          '${options.zoomGesturesEnabled ? 'disable' : 'enable'} zoom'),
      onPressed: () {
        widget.controller.mapsController.updateMapOptions(
          new GoogleMapOptions(
            zoomGesturesEnabled: !options.zoomGesturesEnabled,
          ),
        );
        _reloadOptions();
      },
    );
  }

  void _reloadOptions() {
    setState(() {
      // Do nothing.
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleMapOptions options = widget.controller.mapsController.options;
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
            new Text('camera target: ${_position.target.latitude.toStringAsFixed(4)},'
                '${_position.target.longitude.toStringAsFixed(4)}'),
            new Text('camera zoom: ${_position.zoom}'),
            new Text('camera tilt: ${_position.tilt}'),
            _compassToggler(options),
            _latLngBoundsToggler(options),
            _mapTypeCycler(options),
            _zoomBoundsToggler(options),
            _rotateToggler(options),
            _scrollToggler(options),
            _tiltToggler(options),
            _zoomToggler(options),
          ],
        ),
      ],
    );
  }
}
