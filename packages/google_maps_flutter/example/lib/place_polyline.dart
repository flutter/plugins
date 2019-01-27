// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlacePolylinePage extends Page {
  PlacePolylinePage() : super(const Icon(Icons.place), 'Place polyline');

  @override
  Widget build(BuildContext context) {
    return const PlacePolylineBody();
  }
}

class PlacePolylineBody extends StatefulWidget {
  const PlacePolylineBody();

  @override
  State<StatefulWidget> createState() => PlacePolylineBodyState();
}

class PlacePolylineBodyState extends State<PlacePolylineBody> {
  PlacePolylineBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  GoogleMapController controller;
  int _polylineCount = 0;
  Polyline _selectedPolyline;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    controller.onPolylineTapped.add(_onPolylineTapped);
  }

  @override
  void dispose() {
    controller?.onPolylineTapped?.remove(_onPolylineTapped);
    super.dispose();
  }

  void _onPolylineTapped(Polyline polyline) {
    if (_selectedPolyline != null) {
      _updateSelectedPolyline(
        const PolylineOptions(),
      );
    }
    setState(() {
      _selectedPolyline = polyline;
    });
    _updateSelectedPolyline(
        PolylineOptions(width: 20, color: Colors.pink.value));
  }

  void _updateSelectedPolyline(PolylineOptions changes) {
    controller.updatePolyline(_selectedPolyline, changes);
  }

  int _getColor() {
    int color = 0;
    final Random rnd = Random();
    switch (rnd.nextInt(7)) {
      case 0:
        color = Colors.blue.value;
        break;
      case 1:
        color = Colors.green.value;
        break;
      case 2:
        color = Colors.red.value;
        break;
      case 3:
        color = Colors.orange.value;
        break;
      case 4:
        color = Colors.yellow.value;
        break;
      case 5:
        color = Colors.pink.value;
        break;
      case 6:
        color = Colors.purple.value;
        break;
    }
    return color;
  }

  void _add() {
    final List<LatLng> points = <LatLng>[
      LatLng(
        center.latitude + sin(_polylineCount * pi / 6.0) / 20.0,
        center.longitude + cos(_polylineCount * pi / 6.0) / 20.0,
      ),
      LatLng(
        center.latitude + cos((_polylineCount + 1) * pi / 3.0) / 20.0,
        center.longitude + sin((_polylineCount + 1) * pi / 4.0) / 20.0,
      ),
      LatLng(
        center.latitude + sin((_polylineCount + 2) * pi / 3.0) / 20.0,
        center.longitude + cos((_polylineCount + 1) * pi / 8.0) / 20.0,
      ),
      LatLng(
        center.latitude + cos((_polylineCount + 3) * pi / 3.0) / 10.0,
        center.longitude + cos((_polylineCount + 2) * pi / 3.0) / 15.0,
      )
    ];
    controller.addPolyline(PolylineOptions(
        points: points, color: _getColor(), width: 10, visible: true));
    setState(() {
      _polylineCount += 1;
    });
  }

  void _remove() {
    controller.removePolyline(_selectedPolyline);
    setState(() {
      _selectedPolyline = null;
      _polylineCount -= 1;
    });
  }

  Future<void> _toggleVisible() async {
    _updateSelectedPolyline(
      PolylineOptions(visible: !_selectedPolyline.options.visible),
    );
  }

  Future<void> _changeStartCap() async {
    Cap newCap = Cap.ButtCap;
    switch (_selectedPolyline.options.startCap) {
      case Cap.ButtCap:
        newCap = Cap.RoundCap;
        break;
      case Cap.RoundCap:
        newCap = Cap.SquareCap;
        break;
      default:
        newCap = Cap.ButtCap;
    }
    _updateSelectedPolyline(
      PolylineOptions(startCap: newCap),
    );
  }

  Future<void> _changeEndCap() async {
    Cap newCap = Cap.ButtCap;
    switch (_selectedPolyline.options.endCap) {
      case Cap.ButtCap:
        newCap = Cap.RoundCap;
        break;
      case Cap.RoundCap:
        newCap = Cap.SquareCap;
        break;
      default:
        newCap = Cap.ButtCap;
    }
    _updateSelectedPolyline(
      PolylineOptions(endCap: newCap),
    );
  }

  Future<void> _changeZIndex() async {
    final double current = _selectedPolyline.options.zIndex;
    _updateSelectedPolyline(
      PolylineOptions(zIndex: current == 12.0 ? 0.0 : current + 1.0),
    );
  }

  Future<void> _changeColor() async {
    _updateSelectedPolyline(
      PolylineOptions(color: _getColor()),
    );
  }

  Future<void> _changeWidth() async {
    final double current = _selectedPolyline.options.width;
    _updateSelectedPolyline(
      PolylineOptions(width: current > 40.0 ? 5.0 : current + 3.0),
    );
  }

  Future<void> _changeJointType() async {
    final JointType current = _selectedPolyline.options.jointType;
    JointType nextJointType = JointType.Default;
    switch (current) {
      case JointType.Default:
        nextJointType = JointType.Bevel;
        break;
      case JointType.Bevel:
        nextJointType = JointType.Route;
        break;
      case JointType.Route:
        nextJointType = JointType.Default;
        break;
    }
    _updateSelectedPolyline(
      PolylineOptions(jointType: nextJointType),
    );
  }

  Future<void> _changePattern() async {
    final List<Pattern> current = _selectedPolyline.options.pattern;
    if (current.isNotEmpty) {
      _updateSelectedPolyline(
        const PolylineOptions(pattern: <Pattern>[]),
      );
    } else {
      _updateSelectedPolyline(
        const PolylineOptions(pattern: <Pattern>[
          Pattern(length: 20, patternItem: PatternItem.Dash),
          Pattern(length: 10, patternItem: PatternItem.Gap),
        ]),
      );
    }
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
                          onPressed: (_polylineCount == 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('change zIndex'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeZIndex,
                        ),
                        FlatButton(
                          child: const Text('change color'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _changeColor,
                        ),
                        FlatButton(
                          child: const Text('change start cap'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeStartCap,
                        ),
                        FlatButton(
                          child: const Text('change end cap'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeEndCap,
                        ),
                        FlatButton(
                          child: const Text('change width'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change pattern'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changePattern,
                        ),
                        FlatButton(
                          child: const Text('change joint type'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeJointType,
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
