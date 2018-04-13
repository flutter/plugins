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

  final GoogleMapsOverlayController controller =
      new GoogleMapsOverlayController.fromSize(
    width: 300.0,
    height: 200.0,
    options: const GoogleMapOptions(
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
  final GoogleMapsOverlayController controller;

  const MapUiBody(this.controller);

  @override
  State<StatefulWidget> createState() => new MapUiBodyState();
}

class MapUiBodyState extends State<MapUiBody> {
  Future<GoogleMapOptions> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _optionsFuture = widget.controller.mapsController.getMapOptions();
  }

  Widget _compassToggler(GoogleMapOptions options) {
    return new FlatButton(
      child:
          new Text('${options.compassEnabled ? 'disable' : 'enable'} compass'),
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
          new GoogleMapOptions(compassEnabled: !options.compassEnabled),
        );
        _reloadOptions();
      },
    );
  }

  Widget _latLngBoundsToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
        options.cameraTargetBounds.isBounded
            ? 'release camera target'
            : 'bound camera target',
      ),
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
          new GoogleMapOptions(
            cameraTargetBounds: options.cameraTargetBounds.isBounded
                ? CameraTargetBounds.unbounded
                : const CameraTargetBounds(sydneyBounds),
          ),
        );
        _reloadOptions();
      },
    );
  }

  Widget _zoomBoundsToggler(GoogleMapOptions options) {
    return new FlatButton(
      child: new Text(
          options.zoomBounds.isBounded ? 'release zoom' : 'bound zoom'),
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
          new GoogleMapOptions(
            zoomBounds: options.zoomBounds.isBounded
                ? ZoomBounds.unbounded
                : const ZoomBounds(12.0, 16.0),
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
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
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
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
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
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
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
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
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
      onPressed: () async {
        await widget.controller.mapsController.setMapOptions(
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
      _optionsFuture = widget.controller.mapsController.getMapOptions();
    });
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
            child: new GoogleMapsOverlay(controller: widget.controller),
          ),
        ),
        new FutureBuilder<GoogleMapOptions>(
          future: _optionsFuture,
          builder: (_, AsyncSnapshot<GoogleMapOptions> snapshot) {
            if (!snapshot.hasData) {
              return const Text('Loading settings');
            } else {
              final GoogleMapOptions options = snapshot.data;
              return new Column(
                children: <Widget>[
                  new Text('camera bearing: ${options.cameraPosition.bearing}'),
                  new Text(
                      'camera target: ${options.cameraPosition.target.latitude},${options.cameraPosition.target.longitude}'),
                  new Text('camera zoom: ${options.cameraPosition.zoom}'),
                  new Text('camera tilt: ${options.cameraPosition.tilt}'),
                  _compassToggler(options),
                  _latLngBoundsToggler(options),
                  _mapTypeCycler(options),
                  _zoomBoundsToggler(options),
                  _rotateToggler(options),
                  _scrollToggler(options),
                  _tiltToggler(options),
                  _zoomToggler(options),
                ],
              );
            }
          },
        ),
      ],
    );
  }
}
