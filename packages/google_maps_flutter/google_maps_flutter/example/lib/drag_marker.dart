// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class DragMarkerPage extends GoogleMapExampleAppPage {
  DragMarkerPage() : super(const Icon(Icons.drag_handle), 'Drag marker');

  @override
  Widget build(BuildContext context) {
    return const DragMarkerBody();
  }
}

class DragMarkerBody extends StatefulWidget {
  const DragMarkerBody();

  @override
  State<StatefulWidget> createState() => DragMarkerBodyState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class DragMarkerBodyState extends State<DragMarkerBody> {
  DragMarkerBodyState();
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  GoogleMapController? controller;
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        if (markers.containsKey(selectedMarker)) {
          final Marker resetOld = markers[selectedMarker]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[selectedMarker!] = resetOld;
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

  void _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      this.markerPosition = newPosition;
    });
  }

  void _add() {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      draggable: true,
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 6.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () => _onMarkerTapped(markerId),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Center(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: center,
                zoom: 11.0,
              ),
              markers: markers.values.toSet(),
            ),
          ),
        ),
        Container(
          height: 30,
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              markerPosition == null
                  ? Container()
                  : Expanded(child: Text("lat: ${markerPosition!.latitude}")),
              markerPosition == null
                  ? Container()
                  : Expanded(child: Text("lng: ${markerPosition!.longitude}")),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            TextButton(
              child: const Text('add'),
              onPressed: _add,
            ),
            TextButton(
              child: const Text('remove'),
              onPressed: _remove,
            ),
          ],
        ),
      ],
    );
  }
}
