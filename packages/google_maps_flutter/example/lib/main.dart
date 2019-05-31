// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'animate_camera.dart';
<<<<<<< HEAD
=======
import 'map_click.dart';
import 'map_coordinates.dart';
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
import 'map_ui.dart';
import 'move_camera.dart';
import 'page.dart';
import 'place_circle.dart';
import 'place_marker.dart';
<<<<<<< HEAD

final List<Page> _allPages = <Page>[
  MapUiPage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceMarkerPage(),
=======
import 'place_polygon.dart';
import 'place_polyline.dart';
import 'scrolling_map.dart';

final List<Page> _allPages = <Page>[
  MapUiPage(),
  MapCoordinatesPage(),
  MapClickPage(),
  AnimateCameraPage(),
  MoveCameraPage(),
  PlaceMarkerPage(),
  MarkerIconsPage(),
  ScrollingMapPage(),
  PlacePolylinePage(),
  PlacePolygonPage(),
  PlaceCirclePage(),
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
];

class MapsDemo extends StatelessWidget {
  void _pushPage(BuildContext context, Page page) {
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
  GoogleMapController.init();
  final List<NavigatorObserver> observers = <NavigatorObserver>[];
  for (Page p in _allPages) {
    observers.add(p.controller.overlayController);
  }
  runApp(MaterialApp(home: MapsDemo(), navigatorObservers: observers));
}
