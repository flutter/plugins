// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';
<<<<<<< HEAD
=======
import 'dart:ui';
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceMarkerPage extends Page {
  PlaceMarkerPage() : super(const Icon(Icons.place), 'Place marker');

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
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PlaceMarkerBody(controller);
  }
}

class PlaceMarkerBody extends StatefulWidget {
  final GoogleMapOverlayController controller;

  const PlaceMarkerBody(this.controller);

  @override
  State<StatefulWidget> createState() {
    return PlaceMarkerBodyState(controller.mapController);
  }
}

class PlaceMarkerBodyState extends State<PlaceMarkerBody> {
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  PlaceMarkerBodyState(this.controller);

  final GoogleMapController controller;
  int _markerCount = 0;
  Marker _selectedMarker;

  @override
  void initState() {
    super.initState();
    controller.onMarkerTapped.add(_onMarkerTapped);
  }

  @override
  void dispose() {
    controller.onMarkerTapped.remove(_onMarkerTapped);
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
<<<<<<< HEAD
    final double current = _selectedMarker.options.zIndex;
    _updateSelectedMarker(
      MarkerOptions(zIndex: current == 12.0 ? 0.0 : current + 1.0),
    );
  }
=======
    final Marker marker = markers[selectedMarker];
    final double current = marker.zIndex;
    setState(() {
      markers[selectedMarker] = marker.copyWith(
        zIndexParam: current == 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

// A breaking change to the ImageStreamListener API affects this sample.
// I've updates the sample to use the new API, but as we cannot use the new
// API before it makes it to stable I'm commenting out this sample for now
// TODO(amirh): uncomment this one the ImageStream API change makes it to stable.
// https://github.com/flutter/flutter/issues/33438
//
//  void _setMarkerIcon(BitmapDescriptor assetIcon) {
//    if (selectedMarker == null) {
//      return;
//    }
//
//    final Marker marker = markers[selectedMarker];
//    setState(() {
//      markers[selectedMarker] = marker.copyWith(
//        iconParam: assetIcon,
//      );
//    });
//  }
//
//  Future<BitmapDescriptor> _getAssetIcon(BuildContext context) async {
//    final Completer<BitmapDescriptor> bitmapIcon =
//        Completer<BitmapDescriptor>();
//    final ImageConfiguration config = createLocalImageConfiguration(context);
//
//    const AssetImage('assets/red_square.png')
//        .resolve(config)
//        .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
//      final ByteData bytes =
//          await image.image.toByteData(format: ImageByteFormat.png);
//      final BitmapDescriptor bitmap =
//          BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
//      bitmapIcon.complete(bitmap);
//    }));
//
//    return await bitmapIcon.future;
//  }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(child: GoogleMapOverlay(controller: widget.controller)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('add'),
                      onPressed: (_markerCount == 12) ? null : _add,
                    ),
                    FlatButton(
                      child: const Text('remove'),
                      onPressed: (_selectedMarker == null) ? null : _remove,
                    ),
                    FlatButton(
                      child: const Text('change info'),
                      onPressed: (_selectedMarker == null) ? null : _changeInfo,
                    ),
                    FlatButton(
                      child: const Text('change info anchor'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeInfoAnchor,
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    FlatButton(
                      child: const Text('change alpha'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeAlpha,
                    ),
                    FlatButton(
                      child: const Text('change anchor'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeAnchor,
                    ),
                    FlatButton(
                      child: const Text('toggle draggable'),
                      onPressed:
                          (_selectedMarker == null) ? null : _toggleDraggable,
                    ),
<<<<<<< HEAD
                    FlatButton(
                      child: const Text('toggle flat'),
                      onPressed: (_selectedMarker == null) ? null : _toggleFlat,
                    ),
                    FlatButton(
                      child: const Text('change position'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changePosition,
                    ),
                    FlatButton(
                      child: const Text('change rotation'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeRotation,
                    ),
                    FlatButton(
                      child: const Text('toggle visible'),
                      onPressed:
                          (_selectedMarker == null) ? null : _toggleVisible,
                    ),
                    FlatButton(
                      child: const Text('change zIndex'),
                      onPressed:
                          (_selectedMarker == null) ? null : _changeZIndex,
=======
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
                        // A breaking change to the ImageStreamListener API affects this sample.
                        // I've updates the sample to use the new API, but as we cannot use the new
                        // API before it makes it to stable I'm commenting out this sample for now
                        // TODO(amirh): uncomment this one the ImageStream API change makes it to stable.
                        // https://github.com/flutter/flutter/issues/33438
                        //
                        // FlatButton(
                        //   child: const Text('set marker icon'),
                        //   onPressed: () {
                        //     _getAssetIcon(context).then(
                        //       (BitmapDescriptor icon) {
                        //         _setMarkerIcon(icon);
                        //       },
                        //     );
                        //   },
                        // ),
                      ],
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
