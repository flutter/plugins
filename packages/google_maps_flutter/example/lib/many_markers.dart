// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'page.dart';

const int _kNbPins = 2450;
final int _kNbPinLon = (sqrt(_kNbPins / 2)).round();
final int _kNbPinLat = 2 * _kNbPinLon;
const LatLng _kMapCenter = LatLng(56, -3.5402);
enum MarkerType {
  defaultMarker,
  defaultMarkerWithHue,
  fromAssetImage,
  fromBytes
}
const MarkerType _kMarkerType = MarkerType.defaultMarkerWithHue;

class ManyMarkersPage extends Page {
  ManyMarkersPage()
      : super(const Icon(Icons.place), 'Many markers (wait few seconds...)');

  @override
  Widget build(BuildContext context) {
    return const ManyMarkersBody();
  }
}

class ManyMarkersBody extends StatefulWidget {
  const ManyMarkersBody();

  @override
  State<StatefulWidget> createState() => ManyMarkersBodyState();
}

class ManyMarkersBodyState extends State<ManyMarkersBody> {
  BitmapDescriptor _markerIconFrom;

  @override
  Widget build(BuildContext context) {
    if (_kMarkerType == MarkerType.fromAssetImage) {
      _createMarkerImageFromAsset(context);
    } else if (_kMarkerType == MarkerType.fromBytes) {
      _createMarkerImageFromBytes(context);
    }
    return GoogleMap(
      key: const Key('GoogleMap'),
      initialCameraPosition: const CameraPosition(
        target: _kMapCenter,
        zoom: 5.0,
      ),
      markers: _createMarkers(),
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      for (int y = 0; y < _kNbPinLat; y++)
        for (int x = 1; x <= _kNbPinLon; x++)
          Marker(
            markerId: MarkerId('marker_${y * _kNbPinLon + x}'),
            position: LatLng(47 + y / 5, -6 + x / 5),
            icon: _getMarkerIcon(x),
            infoWindow: InfoWindow(
                title: 'marker_${y * _kNbPinLon + x}',
                snippet: 'marker_${y * _kNbPinLon + x}',
                onTap: () => print('marker_${y * _kNbPinLon + x}')),
          ),
    };
  }

  BitmapDescriptor _getMarkerIcon(int x) {
    switch (_kMarkerType) {
      case MarkerType.defaultMarker:
        return BitmapDescriptor.defaultMarker;
      case MarkerType.defaultMarkerWithHue:
        return BitmapDescriptor.defaultMarkerWithHue((x % 11) * 30.0);
      case MarkerType.fromAssetImage:
      case MarkerType.fromBytes:
        return _markerIconFrom;
    }
    assert(false);
    return null;
  }

  Future<void> _createMarkerImageFromAsset(BuildContext context) async {
    if (_markerIconFrom == null) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'assets/red_square.png')
          .then(_updateBitmap);
    }
  }

  void _updateBitmap(BitmapDescriptor bitmap) {
    setState(() {
      _markerIconFrom = bitmap;
    });
  }

  Future<void> _createMarkerImageFromBytes(BuildContext context) async {
    if (_markerIconFrom == null) {
      _getAssetIcon(context).then(_updateBitmap);
    }
  }

  Future<BitmapDescriptor> _getAssetIcon(BuildContext context) async {
    final Completer<BitmapDescriptor> bitmapIcon =
        Completer<BitmapDescriptor>();
    final ImageConfiguration config = createLocalImageConfiguration(context);

    const AssetImage('assets/red_square.png')
        .resolve(config)
        .addListener(ImageStreamListener((ImageInfo image, bool sync) async {
      final ByteData bytes =
          await image.image.toByteData(format: ImageByteFormat.png);
      final BitmapDescriptor bitmap = BitmapDescriptor.fromBytes(
          bytes.buffer.asUint8List(),
          tag: 'red_square as bytes');
      bitmapIcon.complete(bitmap);
    }));

    return await bitmapIcon.future;
  }
}
