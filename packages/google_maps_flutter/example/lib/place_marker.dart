// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super(const Icon(Icons.place), "Place marker");

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
    ),
  );

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
  Marker _selectedMarker;

  @override
  void initState() {
    super.initState();
    widget.controller.mapController.onMarkerTapped.add((Marker marker) {
      if (_selectedMarker != null) {
        _selectedMarker
            .update(const MarkerOptions(icon: BitmapDescriptor.defaultMarker));
      }
      setState(() {
        _selectedMarker = marker;
      });
      _selectedMarker.update(new MarkerOptions(
          icon: BitmapDescriptor
              .defaultMarkerWithHue(BitmapDescriptor.hueGreen)));
    });
  }

  void _add() {
    widget.controller.mapController.addMarker(new MarkerOptions(
      position: new LatLng(
        center.latitude + sin(_markerCount * pi / 6.0) / 20.0,
        center.longitude + cos(_markerCount * pi / 6.0) / 20.0,
      ),
      infoWindowText: new InfoWindowText('Marker #${_markerCount + 1}', '*'),
    ));
    setState(() {
      _markerCount += 1;
    });
  }

  void _remove() {
    _selectedMarker.remove();
    setState(() {
      _selectedMarker = null;
      _markerCount -= 1;
    });
  }

  void _changePosition() {
    final LatLng current = _selectedMarker.options.position;
    final Offset offset = new Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _selectedMarker.update(
      new MarkerOptions(
        position: new LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeAnchor() {
    final Offset currentAnchor = _selectedMarker.options.anchor;
    final Offset newAnchor =
        new Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _selectedMarker.update(new MarkerOptions(anchor: newAnchor));
  }

  Future<void> _changeInfoAnchor() async {
    final Offset currentAnchor = _selectedMarker.options.infoWindowAnchor;
    final Offset newAnchor =
        new Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _selectedMarker.update(new MarkerOptions(infoWindowAnchor: newAnchor));
  }

  Future<void> _toggleDraggable() async {
    _selectedMarker.update(
        new MarkerOptions(draggable: !_selectedMarker.options.draggable));
  }

  Future<void> _toggleFlat() async {
    _selectedMarker
        .update(new MarkerOptions(flat: !_selectedMarker.options.flat));
  }

  Future<void> _changeInfo() async {
    final InfoWindowText currentInfo = _selectedMarker.options.infoWindowText;
    _selectedMarker.update(new MarkerOptions(
      infoWindowText: new InfoWindowText(
        currentInfo.title,
        currentInfo.snippet + '*',
      ),
    ));
  }

  Future<void> _toggleInfoShown() async {
    _selectedMarker.update(
      new MarkerOptions(
          infoWindowShown: !_selectedMarker.options.infoWindowShown),
    );
  }

  Future<void> _changeAlpha() async {
    final double current = _selectedMarker.options.alpha;
    _selectedMarker.update(
      new MarkerOptions(alpha: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    final double current = _selectedMarker.options.rotation;
    _selectedMarker.update(
      new MarkerOptions(rotation: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    _selectedMarker
        .update(new MarkerOptions(visible: !_selectedMarker.options.visible));
  }

  Future<void> _changeZIndex() async {
    final double current = _selectedMarker.options.zIndex;
    _selectedMarker.update(
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
                      onPressed: (_selectedMarker == null) ? null : _remove,
                    ),
                    new FlatButton(
                      child: const Text('change info'),
                      onPressed: (_selectedMarker == null) ? null : _changeInfo,
                    ),
                    new FlatButton(
                      child: const Text('change info anchor'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeInfoAnchor,
                    ),
                    new FlatButton(
                      child: const Text('toggle info shown'),
                      onPressed:
                          (_selectedMarker == null) ? null : _toggleInfoShown,
                    ),
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('change alpha'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeAlpha,
                    ),
                    new FlatButton(
                      child: const Text('change anchor'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeAnchor,
                    ),
                    new FlatButton(
                      child: const Text('toggle draggable'),
                      onPressed:
                          (_selectedMarker == null) ? null : _toggleDraggable,
                    ),
                    new FlatButton(
                      child: const Text('toggle flat'),
                      onPressed: (_selectedMarker == null) ? null : _toggleFlat,
                    ),
                    new FlatButton(
                      child: const Text('change position'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changePosition,
                    ),
                    new FlatButton(
                      child: const Text('change rotation'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeRotation,
                    ),
                    new FlatButton(
                      child: const Text('toggle visible'),
                      onPressed:
                          (_selectedMarker == null) ? null : _toggleVisible,
                    ),
                    new FlatButton(
                      child: const Text('change zIndex'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeZIndex,
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
