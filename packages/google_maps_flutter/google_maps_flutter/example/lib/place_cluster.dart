// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'page.dart';

class PlaceClusterPage extends Page {
  PlaceClusterPage() : super(const Icon(Icons.place), 'Place marker clusterer');

  @override
  Widget build(BuildContext context) {
    return const PlaceClusterBody();
  }
}

class PlaceClusterBody extends StatefulWidget {
  const PlaceClusterBody();

  @override
  State<StatefulWidget> createState() => PlaceClusterBodyState();
}

typedef Marker MarkerUpdateAction(Marker marker);

class PlaceClusterBodyState extends State<PlaceClusterBody> {
  PlaceClusterBodyState();
  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  GoogleMapController controller;
  Map<MarkerId, ClusterItem> clusterItems = <MarkerId, ClusterItem>{};
  MarkerId selectedMarker;
  int _markerIdCounter = 1;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onClusterMarkerTapped(MarkerId markerId) {
    final ClusterItem tappedClusterItem = clusterItems[markerId];
    if (tappedClusterItem != null) {
      setState(() {
        if (clusterItems.containsKey(selectedMarker)) {
          final ClusterItem resetOld = clusterItems[selectedMarker]
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          clusterItems[selectedMarker] = resetOld;
        }
        selectedMarker = markerId;
        final ClusterItem newClusterItem = tappedClusterItem.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        clusterItems[markerId] = newClusterItem;
      });
    }
  }

  void _add() {
    final int markerCount = clusterItems.length;

    if (markerCount == 48) {
      return;
    }

    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);

    final ClusterItem clusterItem = ClusterItem(
      icon: BitmapDescriptor.defaultMarkerWithHue(160),
      markerId: markerId,
      position: LatLng(
        center.latitude + sin(_markerIdCounter * pi / 24.0) / 20.0,
        center.longitude + cos(_markerIdCounter * pi / 24.0) / 20.0,
      ),
      infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
      onTap: () {
        _onClusterMarkerTapped(markerId);
      },
    );

    setState(() {
      clusterItems[markerId] = clusterItem;
    });
  }

  void _remove() {
    setState(() {
      if (clusterItems.containsKey(selectedMarker)) {
        clusterItems.remove(selectedMarker);
      }
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
              // TODO(iskakaushik): Remove this when collection literals makes it to stable.
              // https://github.com/flutter/flutter/issues/28312
              // ignore: prefer_collection_literals
              clusterItems: Set<ClusterItem>.of(clusterItems.values),
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
