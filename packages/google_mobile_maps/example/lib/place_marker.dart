// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super(const Icon(Icons.place), "Place marker");

  final GoogleMapOverlayController controller =
      new GoogleMapOverlayController.fromSize(
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
    return new PlaceMarkerBody(controller);
  }
}

class PlaceMarkerBody extends StatefulWidget {
  final GoogleMapOverlayController controller;

  const PlaceMarkerBody(this.controller);

  @override
  State<StatefulWidget> createState() => new PlaceMarkerBodyState();
}

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  static const LatLng center = const LatLng(-33.86711, 151.1947171);

  int _markerCount = 0;
  Marker _marker;

  @override
  void initState() {
    super.initState();
    widget.controller.mapsController.onMarkerTapped = (Marker marker) {
      if (_marker != null) {
        _marker
            .update(const MarkerOptions(icon: BitmapDescriptor.defaultMarker));
      }
      setState(() {
        _marker = marker;
      });
      _marker.update(new MarkerOptions(
          icon: BitmapDescriptor
              .defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    };
    widget.controller.mapsController.addListener(() {
      setState(() {
        // rebuild
      });
    });
  }

  void _add() {
    widget.controller.mapsController.addMarker(new MarkerOptions(
      position: new LatLng(
        center.latitude + sin(_markerCount * pi / 6.0) / 20.0,
        center.longitude + cos(_markerCount * pi / 6.0) / 20.0,
      ),
      infoWindowText: new InfoWindowText('Marker #${_markerCount + 1}', '*'),
    ));
    setState(() {
      _markerCount++;
    });
  }

  void _remove() {
    _marker?.remove();
    setState(() {
      _marker = null;
    });
  }

  void _changePosition() {
    final LatLng current = _marker.options.position;
    final Offset offset = new Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _marker?.update(
      new MarkerOptions(
        position: new LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeAnchor() {
    final Offset currentAnchor = _marker.options.anchor;
    final Offset newAnchor =
        new Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _marker.update(new MarkerOptions(anchor: newAnchor));
  }

  Future<void> _changeInfoAnchor() async {
    final Offset currentAnchor = _marker.options.infoWindowAnchor;
    final Offset newAnchor =
        new Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _marker.update(new MarkerOptions(infoWindowAnchor: newAnchor));
  }

  Future<void> _toggleDraggable() async {
    _marker.update(new MarkerOptions(draggable: !_marker.options.draggable));
  }

  Future<void> _toggleFlat() async {
    _marker.update(new MarkerOptions(flat: !_marker.options.flat));
  }

  Future<void> _changeInfo() async {
    final InfoWindowText currentInfo = _marker.options.infoWindowText;
    _marker.update(new MarkerOptions(
      infoWindowText: new InfoWindowText(
        currentInfo.title,
        currentInfo.snippet + '*',
      ),
    ));
  }

  Future<void> _toggleInfoShown() async {
    _marker.update(
      new MarkerOptions(infoWindowShown: !_marker.options.infoWindowShown),
    );
  }

  Future<void> _changeAlpha() async {
    final double current = _marker.options.alpha;
    _marker.update(
      new MarkerOptions(alpha: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    final double current = _marker.options.rotation;
    _marker.update(
      new MarkerOptions(rotation: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    _marker.update(new MarkerOptions(visible: !_marker.options.visible));
  }

  Future<void> _changeZIndex() async {
    final double current = _marker.options.zIndex;
    _marker.update(
      new MarkerOptions(zIndex: current == 12.0 ? 0.0 : current + 1.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Center(child: new GoogleMapOverlay(controller: widget.controller)),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('add'),
                      onPressed: (_markerCount == 12) ? null : _add,
                    ),
                    new FlatButton(
                      child: const Text('remove'),
                      onPressed: (_marker == null) ? null : _remove,
                    ),
                    new FlatButton(
                      child: const Text('change info'),
                      onPressed: (_marker == null) ? null : _changeInfo,
                    ),
                    new FlatButton(
                      child: const Text('change info anchor'),
                      onPressed: (_marker == null) ? null : _changeInfoAnchor,
                    ),
                    new FlatButton(
                      child: const Text('toggle info shown'),
                      onPressed: (_marker == null) ? null : _toggleInfoShown,
                    ),
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('change alpha'),
                      onPressed: (_marker == null) ? null : _changeAlpha,
                    ),
                    new FlatButton(
                      child: const Text('change anchor'),
                      onPressed: (_marker == null) ? null : _changeAnchor,
                    ),
                    new FlatButton(
                      child: const Text('toggle draggable'),
                      onPressed: (_marker == null) ? null : _toggleDraggable,
                    ),
                    new FlatButton(
                      child: const Text('toggle flat'),
                      onPressed: (_marker == null) ? null : _toggleFlat,
                    ),
                    new FlatButton(
                      child: const Text('change position'),
                      onPressed: (_marker == null) ? null : _changePosition,
                    ),
                    new FlatButton(
                      child: const Text('change rotation'),
                      onPressed: (_marker == null) ? null : _changeRotation,
                    ),
                    new FlatButton(
                      child: const Text('toggle visible'),
                      onPressed: (_marker == null) ? null : _toggleVisible,
                    ),
                    new FlatButton(
                      child: const Text('change zIndex'),
                      onPressed: (_marker == null) ? null : _changeZIndex,
                    ),
                  ],
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
