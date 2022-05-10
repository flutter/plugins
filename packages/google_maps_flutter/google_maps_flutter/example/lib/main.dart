// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/lite_mode.dart';
import 'animate_camera.dart';
import 'map_click.dart';
import 'map_coordinates.dart';
import 'map_ui.dart';
import 'marker_icons.dart';
import 'move_camera.dart';
import 'padding.dart';
import 'page.dart';
import 'place_circle.dart';
import 'place_marker.dart';
import 'place_polygon.dart';
import 'place_polyline.dart';
import 'scrolling_map.dart';
import 'snapshot.dart';
import 'tile_overlay.dart';

final List<GoogleMapExampleAppPage> _allPages = <GoogleMapExampleAppPage>[
  const MapUiPage(),
  const MapCoordinatesPage(),
  const MapClickPage(),
  const AnimateCameraPage(),
  const MoveCameraPage(),
  const PlaceMarkerPage(),
  const MarkerIconsPage(),
  const ScrollingMapPage(),
  const PlacePolylinePage(),
  const PlacePolygonPage(),
  const PlaceCirclePage(),
  const PaddingPage(),
  const SnapshotPage(),
  const LiteModePage(),
  const TileOverlayPage(),
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, GoogleMapExampleAppPage page) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
              appBar: AppBar(title: Text(page.title)),
              body: page,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GoogleMaps examples')),
      body: ListView.builder(
        itemCount: _allPages.length,
        itemBuilder: (_, int index) => ListTile(
          leading: _allPages[index].leading,
          title: Text(_allPages[index].title),
          onTap: () => _pushPage(context, _allPages[index]),
        ),
      ),
    );
  }
}

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(MaterialApp(home: MapsDemo()));
}
