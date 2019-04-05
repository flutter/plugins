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
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  PolylineId selectedPolyline;
  int _polylineIdCounter = 1;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    final Polyline tappedPolyline = polylines[polylineId];
    if (tappedPolyline != null) {
      setState(() {
        if (polylines.containsKey(selectedPolyline)) {
          final Polyline resetOld = polylines[selectedPolyline].copyWith();
          polylines[selectedPolyline] = resetOld;
        }
        selectedPolyline = polylineId;
        final Polyline newPolyline = tappedPolyline.copyWith();
        polylines[polylineId] = newPolyline;
      });
    }
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
    if (_polylineIdCounter == 12) {
      return;
    }
    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final List<LatLng> points = <LatLng>[
      LatLng(
        center.latitude + sin(_polylineIdCounter * pi / 6.0) / 20.0,
        center.longitude + cos(_polylineIdCounter * pi / 6.0) / 20.0,
      ),
      LatLng(
        center.latitude + cos((_polylineIdCounter + 1) * pi / 3.0) / 20.0,
        center.longitude + sin((_polylineIdCounter + 1) * pi / 4.0) / 20.0,
      ),
      LatLng(
        center.latitude + sin((_polylineIdCounter + 2) * pi / 3.0) / 20.0,
        center.longitude + cos((_polylineIdCounter + 1) * pi / 8.0) / 20.0,
      ),
      LatLng(
        center.latitude + cos((_polylineIdCounter + 3) * pi / 3.0) / 10.0,
        center.longitude + cos((_polylineIdCounter + 2) * pi / 3.0) / 15.0,
      )
    ];

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      points: points,
      clickable: true,
      color: _getColor(),
      width: 10,
      visible: true,
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );
    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  void _remove() {
    setState(() {
      if (polylines.containsKey(selectedPolyline)) {
        polylines.remove(selectedPolyline);
      }
    });
  }

  Future<void> _toggleVisible() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        visibleParam: !polyline.visible,
      );
    });
  }

  Future<void> _changeStartCap() async {
    Cap newCap = Cap.ButtCap;
    final Polyline polyline = polylines[selectedPolyline];
    switch (polyline.startCap) {
      case Cap.ButtCap:
        newCap = Cap.RoundCap;
        break;
      case Cap.RoundCap:
        newCap = Cap.SquareCap;
        break;
      default:
        newCap = Cap.ButtCap;
    }

    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        startCapParam: newCap,
      );
    });
  }

  Future<void> _changeEndCap() async {
    Cap newCap = Cap.ButtCap;
    final Polyline polyline = polylines[selectedPolyline];

    switch (polyline.endCap) {
      case Cap.ButtCap:
        newCap = Cap.RoundCap;
        break;
      case Cap.RoundCap:
        newCap = Cap.SquareCap;
        break;
      default:
        newCap = Cap.ButtCap;
    }
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        endCapParam: newCap,
      );
    });
  }

  Future<void> _changeZIndex() async {
    final Polyline polyline = polylines[selectedPolyline];
    final double current = polyline.zIndex;
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        zIndexParam: current == 12.0 ? 0.0 : current + 1.0,
      );
    });
  }

  Future<void> _changeColor() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        colorParam: _getColor(),
      );
    });
  }

  Future<void> _changeWidth() async {
    final Polyline polyline = polylines[selectedPolyline];
    final double current = polyline.width;
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        widthParam: current > 40.0 ? 5.0 : current + 3.0,
      );
    });
  }

  Future<void> _changeJointType() async {
    JointType nextJointType = JointType.Default;
    final Polyline polyline = polylines[selectedPolyline];
    final JointType current = polyline.jointType;
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
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        jointTypeParam: nextJointType,
      );
    });
  }

  Future<void> _changePattern() async {
    final Polyline polyline = polylines[selectedPolyline];
    final List<Pattern> current = polyline.pattern;
    if (current.isNotEmpty) {
      setState(() {
        polylines[selectedPolyline] = polyline.copyWith(
          patternParam: <Pattern>[],
        );
      });
    } else {
      setState(() {
        polylines[selectedPolyline] = polyline.copyWith(patternParam: <Pattern>[
          const Pattern(length: 20, patternItem: PatternItem.Dash),
          const Pattern(length: 10, patternItem: PatternItem.Gap),
        ]);
      });
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
              polylines: Set<Polyline>.of(polylines.values),
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
                          onPressed: (_polylineIdCounter >= 12) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed:
                              (selectedPolyline == null) ? null : _remove,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('change zIndex'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeZIndex,
                        ),
                        FlatButton(
                          child: const Text('change color'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeColor,
                        ),
                        FlatButton(
                          child: const Text('change start cap'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _changeStartCap,
                        ),
                        FlatButton(
                          child: const Text('change end cap'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeEndCap,
                        ),
                        FlatButton(
                          child: const Text('change width'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change pattern'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _changePattern,
                        ),
                        FlatButton(
                          child: const Text('change joint type'),
                          onPressed: (selectedPolyline == null)
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
