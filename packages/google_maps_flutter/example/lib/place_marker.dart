// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super(const Icon(Icons.place), 'Place marker');

  @override
  Widget build(BuildContext context) {
    return const PlaceMarkerBody();
  }
}

class PlaceMarkerBody extends StatefulWidget {
  const PlaceMarkerBody();

  @override
  State<StatefulWidget> createState() => PlaceMarkerBodyState();
}

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  PlaceMarkerBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  GoogleMapController controller;
  int _markerCount = 0;
  Marker _selectedMarker;
//  Marker _selectedMarker = Marker(
//    "aaijielkflk18",
//      MarkerOptions(
//    position: LatLng(
//      center.latitude + sin(pi / 6.0) / 20.0,
//      center.longitude + cos(pi / 6.0) / 20.0,
//    ),
//    infoWindowText: InfoWindowText('Marker #1', '*'),
//  ));

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    controller.onMarkerTapped.add(_onMarkerTapped);
  }

  @override
  void dispose() {
    controller?.onMarkerTapped?.remove(_onMarkerTapped);
    super.dispose();
  }

  void _onMarkerTapped(Marker marker) {
    if (_selectedMarker != null) {
      _updateSelectedMarker(
        const MarkerOptions(icon: BitmapDescriptor.defaultMarker),
      );
    }
    setState(() {
      _selectedMarker = marker;
    });
    _updateSelectedMarker(
      MarkerOptions(
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      ),
    );
  }

  void _updateSelectedMarker(MarkerOptions changes) {
    controller.updateMarker(_selectedMarker, changes);
  }

  void _add() {
    controller.addMarker(MarkerOptions(
      position: LatLng(
        center.latitude + sin(_markerCount * pi / 6.0) / 20.0,
        center.longitude + cos(_markerCount * pi / 6.0) / 20.0,
      ),
      infoWindowText: InfoWindowText('Marker #${_markerCount + 1}', '*'),
    ));
    setState(() {
      _markerCount += 1;
    });
  }

  void _remove() {
    controller.removeMarker(_selectedMarker);
    setState(() {
      _selectedMarker = null;
      _markerCount -= 1;
    });
  }

  void _changePosition() {
    final LatLng current = _selectedMarker.options.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _updateSelectedMarker(
      MarkerOptions(
        position: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeAnchor() {
    final Offset currentAnchor = _selectedMarker.options.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _updateSelectedMarker(MarkerOptions(anchor: newAnchor));
  }

  Future<void> _changeInfoAnchor() async {
    final Offset currentAnchor = _selectedMarker.options.infoWindowAnchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _updateSelectedMarker(MarkerOptions(infoWindowAnchor: newAnchor));
  }

  Future<void> _toggleDraggable() async {
    _updateSelectedMarker(
      MarkerOptions(draggable: !_selectedMarker.options.draggable),
    );
  }

  Future<void> _toggleFlat() async {
    _updateSelectedMarker(MarkerOptions(flat: !_selectedMarker.options.flat));
  }

  Future<void> _changeInfo() async {
    final InfoWindowText currentInfo = _selectedMarker.options.infoWindowText;
    _updateSelectedMarker(MarkerOptions(
      infoWindowText: InfoWindowText(
        currentInfo.title,
        currentInfo.snippet + '*',
      ),
    ));
  }

  Future<void> _changeAlpha() async {
    final double current = _selectedMarker.options.alpha;
    _updateSelectedMarker(
      MarkerOptions(alpha: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    final double current = _selectedMarker.options.rotation;
    _updateSelectedMarker(
      MarkerOptions(rotation: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    _updateSelectedMarker(
      MarkerOptions(visible: !_selectedMarker.options.visible),
    );
  }

  Future<void> _changeZIndex() async {
    final double current = _selectedMarker.options.zIndex;
    _updateSelectedMarker(
      MarkerOptions(zIndex: current == 12.0 ? 0.0 : current + 1.0),
    );
  }

  Widget _button(
      {@required String text, @required VoidCallback onPressed, Color color}) {
    color ??= Colors.lightBlue[700];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: RaisedButton(
        color: color,
        textColor: Colors.white,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: SizedBox(
              width: 300.0,
              height: 200.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                options: GoogleMapOptions(
                  cameraPosition: const CameraPosition(
                    target: LatLng(-33.852, 151.211),
                    zoom: 11.0,
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3.5,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            children: <Widget>[
              _button(
                text: 'add',
                onPressed: (_markerCount == 12) ? null : _add,
                color: Colors.green[700],
              ),
              _button(
                text: 'remove',
                onPressed: (_selectedMarker == null) ? null : _remove,
                color: Colors.red[700],
              ),
              _button(
                text: 'change info',
                onPressed: (_selectedMarker == null) ? null : _changeInfo,
              ),
              _button(
                text: 'change info anchor',
                onPressed: (_selectedMarker == null) ? null : _changeInfoAnchor,
              ),
              _button(
                text: 'change alpha',
                onPressed: (_selectedMarker == null) ? null : _changeAlpha,
              ),
              _button(
                text: 'change anchor',
                onPressed: (_selectedMarker == null) ? null : _changeAnchor,
              ),
              _button(
                text: 'toggle draggable',
                onPressed: (_selectedMarker == null) ? null : _toggleDraggable,
              ),
              _button(
                text: 'toggle flat',
                onPressed: (_selectedMarker == null) ? null : _toggleFlat,
              ),
              _button(
                text: 'change position',
                onPressed: (_selectedMarker == null) ? null : _changePosition,
              ),
              _button(
                text: 'change rotation',
                onPressed: (_selectedMarker == null) ? null : _changeRotation,
              ),
              _button(
                text: 'toggle visible',
                onPressed: (_selectedMarker == null) ? null : _toggleVisible,
              ),
              _button(
                text: 'change zIndex',
                onPressed: (_selectedMarker == null) ? null : _changeZIndex,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
