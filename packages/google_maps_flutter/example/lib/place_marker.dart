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

typedef Marker MarkerUpdateAction(Marker marker);

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  PlaceMarkerBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateSelectedMarker(MarkerUpdateAction update) {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        final Marker newMarker = update(markers[selectedMarker]);
        markers[selectedMarker] = newMarker;
      }
    });
  }

  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    print(markerIdVal);
    final MarkerId markerId = MarkerId(markerIdVal);

    void _onMarkerTapped() {
      final Marker tappedMarker = markers[markerId];
      if (tappedMarker != null) {
        setState(() {
          if (markers.containsKey(selectedMarker)) {
            final Marker resetOld = markers[selectedMarker]
                .copyWith(iconParam: BitmapDescriptor.defaultMarker);
            markers[selectedMarker] = resetOld;
          }
          selectedMarker = markerId;
          final Marker newMarker = tappedMarker.copyWith(
            iconParam: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          );
          markers[markerId] = newMarker;
        });
      }
    }

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: _onMarkerTapped,
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _remove() {
    setState(() {
      if (markers.containsKey(selectedMarker)) {
        markers.remove(selectedMarker);
      }
    });
  }

  void _changePosition() {
    _updateSelectedMarker((Marker m) {
      final LatLng current = m.position;
      final Offset offset = Offset(
        center.latitude - current.latitude,
        center.longitude - current.longitude,
      );
      return m.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  void _changeAnchor() {
    _updateSelectedMarker((Marker m) {
      final Offset currentAnchor = m.anchor;
      final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
      return m.copyWith(
        anchorParam: newAnchor,
      );
    });
  }

  Future<void> _changeInfoAnchor() async {
    _updateSelectedMarker((Marker m) {
      final Offset currentAnchor = m.infoWindow.anchor;
      final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
      return m.copyWith(
        infoWindowParam: m.infoWindow.copyWith(
          anchorParam: newAnchor,
        ),
      );
    });
  }

  Future<void> _toggleDraggable() async {
    _updateSelectedMarker((Marker m) {
      return m.copyWith(
        draggableParam: !m.draggable,
      );
    });
  }

  Future<void> _toggleFlat() async {
    _updateSelectedMarker((Marker m) {
      return m.copyWith(
        flatParam: !m.flat,
      );
    });
  }

  Future<void> _changeInfo() async {
    _updateSelectedMarker((Marker m) {
      final String newSnippet = m.infoWindow.snippet + '*';
      return m.copyWith(
        infoWindowParam: m.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha() async {
    _updateSelectedMarker((Marker m) {
      final double current = m.alpha;
      return m.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _changeRotation() async {
    _updateSelectedMarker((Marker m) {
      final double current = m.rotation;
      return m.copyWith(
        rotationParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }

  Future<void> _toggleVisible() async {
    _updateSelectedMarker((Marker m) {
      return m.copyWith(
        visibleParam: !m.visible,
      );
    });
  }

  Future<void> _changeZIndex() async {
    _updateSelectedMarker((Marker m) {
      final double current = m.zIndex;
      return m.copyWith(
        zIndexParam: current == 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(markers.values),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('add'),
                          onPressed: _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: _remove,
                        ),
                        FlatButton(
                          child: const Text('change info'),
                          onPressed: _changeInfo,
                        ),
                        FlatButton(
                          child: const Text('change info anchor'),
                          onPressed: _changeInfoAnchor,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change alpha'),
                          onPressed: _changeAlpha,
                        ),
                        FlatButton(
                          child: const Text('change anchor'),
                          onPressed: _changeAnchor,
                        ),
                        FlatButton(
                          child: const Text('toggle draggable'),
                          onPressed: _toggleDraggable,
                        ),
                        FlatButton(
                          child: const Text('toggle flat'),
                          onPressed: _toggleFlat,
                        ),
                        FlatButton(
                          child: const Text('change position'),
                          onPressed: _changePosition,
                        ),
                        FlatButton(
                          child: const Text('change rotation'),
                          onPressed: _changeRotation,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed: _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('change zIndex'),
                          onPressed: _changeZIndex,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
