// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';
import 'animate_camera.dart';
import 'move_camera.dart';
import 'page.dart';
import 'place_marker.dart';

final List<Page> _allPages = <Page>[
  new AnimateCameraPage(),
  new MoveCameraPage(),
  new PlaceMarkerPage(),
];

class MapsDemo extends StatefulWidget {
  @override
  MapsDemoState createState() => new MapsDemoState();
}

class MapsDemoState extends State<MapsDemo>
    with SingleTickerProviderStateMixin {
  TabController _controller;
  PlatformOverlayController _activeOverlayController;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(vsync: this, length: _allPages.length);
    _controller.addListener(() {
      if (_controller.indexIsChanging) {
        _activeOverlayController?.deactivateOverlay();
        _activeOverlayController = null;
      } else {
        _activeOverlayController =
            _allPages[_controller.index].overlayController;
        _activeOverlayController.activateOverlay();
      }
    });
    _activeOverlayController = _allPages[_controller.index].overlayController;
    _activeOverlayController.activateOverlay();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Map controls'),
        bottom: new TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _allPages.map((Page page) {
            return new Tab(text: page.title);
          }).toList(),
        ),
      ),
      body: new NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotification) {
          if (scrollNotification.depth != 0) {
            return;
          }
          if (scrollNotification is ScrollStartNotification &&
              _activeOverlayController != null) {
            _activeOverlayController.deactivateOverlay();
            _activeOverlayController = null;
          }
        },
        child: new TabBarView(
            controller: _controller,
            children: _allPages.map((Page page) {
              return new Container(
                key: new ObjectKey(page.title),
                padding: const EdgeInsets.all(12.0),
                child: new Card(child: page),
              );
            }).toList()),
      ),
    );
  }
}

void main() {
  runApp(new MaterialApp(home: new MapsDemo()));
}
