import 'dart:math';

// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super(const Icon(Icons.place), "Place marker", "Single");

  final GoogleMapsOverlayController controller =
      new GoogleMapsOverlayController.fromSize(300.0, 200.0)
        ..mapsController.moveCamera(CameraUpdate.newLatLngZoom(
          const LatLng(-33.852, 151.211),
          11.0,
        ));

  @override
  PlatformOverlayController get overlayController =>
      controller.overlayController;

  @override
  Widget build(BuildContext context) {
    return new PlaceMarkerBody(controller);
  }
}

class PlaceMarkerBody extends StatefulWidget {
  final GoogleMapsOverlayController controller;

  const PlaceMarkerBody(this.controller);

  @override
  State<StatefulWidget> createState() => new PlaceMarkerBodyState();
}

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  static const LatLng center = const LatLng(-33.86711, 151.1947171);

  final List<Future<Marker>> markers = <Future<Marker>>[];
  int _nextAlpha = 1;
  int _nextHue = 1;
  int _nextPosition = 1;
  int _nextRotation = 1;
  int _nextAnchor = 1;
  int _nextInfoWindowAnchor = 7;
  int _nextTitle = 1;
  int _nextZIndex = 1;

  void _add() {
    setState(() {
      markers.add(
        widget.controller.mapsController.addMarker(
          new MarkerOptions(
            position: new LatLng(
              center.latitude + sin(markers.length * pi / 6.0) / 20.0,
              center.longitude + cos(markers.length * pi / 6.0) / 20.0,
            ),
            zIndex: markers.length.toDouble(),
            icon: BitmapDescriptor.defaultMarkerWithHue(30.0 * markers.length),
          ),
        ),
      );
    });
  }

  Future<void> _remove() async {
    final Marker marker = await markers.last;
    setState(() {
      markers.removeLast();
    });
    await marker.remove();
  }

  Future<void> _showInfo() async {
    final Marker marker = await markers.last;
    await marker.showInfoWindow();
  }

  Future<void> _hideInfo() async {
    final Marker marker = await markers.last;
    await marker.hideInfoWindow();
  }

  Future<void> _changePosition() async {
    final Marker marker = await markers.last;
    final LatLng position = new LatLng(
      center.latitude + sin(_nextPosition * pi / 6.0) / 20.0,
      center.longitude + cos(_nextPosition * pi / 6.0) / 20.0,
    );
    setState(() {
      _nextPosition = (_nextPosition + 1) % 12;
    });
    await marker.update(marker.options.copyWith(position: position));
  }

  Future<void> _changeAnchor() async {
    final Marker marker = await markers.last;
    final Offset offset = new Offset(
      (sin(_nextAnchor * pi / 6.0) + 1.0) / 2.0,
      (cos(_nextAnchor * pi / 6.0) + 1.0) / 2.0,
    );
    setState(() {
      _nextAnchor = (_nextAnchor + 1) % 12;
    });
    await marker.update(marker.options.copyWith(anchor: offset));
  }

  Future<void> _changeInfoAnchor() async {
    final Marker marker = await markers.last;
    final Offset offset = new Offset(
      (sin(_nextInfoWindowAnchor * pi / 6.0) + 1.0) / 2.0,
      (cos(_nextInfoWindowAnchor * pi / 6.0) + 1.0) / 2.0,
    );
    setState(() {
      _nextInfoWindowAnchor = (_nextInfoWindowAnchor + 1) % 12;
    });
    await marker.update(marker.options.copyWith(infoWindowAnchor: offset));
  }

  Future<void> _toggleDraggable() async {
    final Marker marker = await markers.last;
    await marker.update(
      marker.options.copyWith(draggable: !marker.options.draggable),
    );
  }

  Future<void> _toggleFlat() async {
    final Marker marker = await markers.last;
    await marker.update(
      marker.options.copyWith(flat: !marker.options.flat),
    );
  }

  Future<void> _changeInfo() async {
    final Marker marker = await markers.last;
    final String title = _nextTitle == 0 ? null : 'Title $_nextTitle';
    final String snippet = _nextTitle % 2 == 0 ? null : 'Snippet $_nextTitle';
    setState(() {
      _nextTitle = (_nextTitle + 1) % 12;
    });
    await marker.update(
      marker.options.copyWith(title: title, snippet: snippet),
    );
  }

  Future<void> _changeIcon() async {
    final Marker marker = await markers.last;
    final BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(
      _nextHue * 30.0,
    );
    setState(() {
      _nextHue = (_nextHue + 1) % 12;
    });
    await marker.update(marker.options.copyWith(icon: icon));
  }

  Future<void> _changeAlpha() async {
    final Marker marker = await markers.last;
    final double alpha = 1.0 - _nextAlpha / 12.0;
    setState(() {
      _nextAlpha = (_nextAlpha + 1) % 12;
    });
    await marker.update(marker.options.copyWith(alpha: alpha));
  }

  Future<void> _changeRotation() async {
    final Marker marker = await markers.last;
    final double rotation = _nextRotation * 30.0;
    setState(() {
      _nextRotation = (_nextRotation + 1) % 12;
    });
    await marker.update(
      marker.options.copyWith(rotation: rotation),
    );
  }

  Future<void> _changeZIndex() async {
    final Marker marker = await markers.last;
    final double zIndex = _nextZIndex.toDouble();
    setState(() {
      _nextZIndex = (_nextZIndex + 1) % 12;
    });
    await marker.update(marker.options.copyWith(zIndex: zIndex));
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        new Center(child: new GoogleMapsOverlay(controller: widget.controller)),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('add'),
                      onPressed: (markers.length == 12) ? null : _add,
                    ),
                    new FlatButton(
                      child: const Text('remove'),
                      onPressed: (markers.isEmpty) ? null : _remove,
                    ),
                    new FlatButton(
                      child: const Text('show info'),
                      onPressed: (markers.isEmpty) ? null : _showInfo,
                    ),
                    new FlatButton(
                      child: const Text('hide info'),
                      onPressed: (markers.isEmpty) ? null : _hideInfo,
                    ),
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new FlatButton(
                      child: const Text('change position'),
                      onPressed: (markers.isEmpty) ? null : _changePosition,
                    ),
                    new FlatButton(
                      child: const Text('change anchor'),
                      onPressed: (markers.isEmpty) ? null : _changeAnchor,
                    ),
                    new FlatButton(
                      child: const Text('change info anchor'),
                      onPressed: (markers.isEmpty) ? null : _changeInfoAnchor,
                    ),
                    new FlatButton(
                      child: const Text('toggle draggable'),
                      onPressed: (markers.isEmpty) ? null : _toggleDraggable,
                    ),
                    new FlatButton(
                      child: const Text('toggle flat'),
                      onPressed: (markers.isEmpty) ? null : _toggleFlat,
                    ),
                    new FlatButton(
                      child: const Text('change info'),
                      onPressed: (markers.isEmpty) ? null : _changeInfo,
                    ),
                    new FlatButton(
                      child: const Text('change color'),
                      onPressed: (markers.isEmpty) ? null : _changeIcon,
                    ),
                    new FlatButton(
                      child: const Text('change alpha'),
                      onPressed: (markers.isEmpty) ? null : _changeAlpha,
                    ),
                    new FlatButton(
                      child: const Text('change rotation'),
                      onPressed: (markers.isEmpty) ? null : _changeRotation,
                    ),
                    new FlatButton(
                      child: const Text('change zIndex'),
                      onPressed: (markers.isEmpty) ? null : _changeZIndex,
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
