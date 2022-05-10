// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlacePolylinePage extends GoogleMapExampleAppPage {
  const PlacePolylinePage()
      : super(const Icon(Icons.linear_scale), 'Place polyline');

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

  GoogleMapController? controller;
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 0;
  PolylineId? selectedPolyline;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling polyline width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  int jointTypesIndex = 0;
  List<JointType> jointTypes = <JointType>[
    JointType.mitered,
    JointType.bevel,
    JointType.round
  ];

  // Values when toggling polyline end cap type
  int endCapsIndex = 0;
  List<Cap> endCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline start cap type
  int startCapsIndex = 0;
  List<Cap> startCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline pattern
  int patternsIndex = 0;
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[],
    <PatternItem>[
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)],
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)],
  ];

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _remove(PolylineId polylineId) {
    setState(() {
      if (polylines.containsKey(polylineId)) {
        polylines.remove(polylineId);
      }
      selectedPolyline = null;
    });
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 5,
      points: _createPoints(),
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  void _toggleGeodesic(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        geodesicParam: !polyline.geodesic,
      );
    });
  }

  void _toggleVisible(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        visibleParam: !polyline.visible,
      );
    });
  }

  void _changeColor(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        colorParam: colors[++colorsIndex % colors.length],
      );
    });
  }

  void _changeWidth(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        widthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  void _changeJointType(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        jointTypeParam: jointTypes[++jointTypesIndex % jointTypes.length],
      );
    });
  }

  void _changeEndCap(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        endCapParam: endCaps[++endCapsIndex % endCaps.length],
      );
    });
  }

  void _changeStartCap(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        startCapParam: startCaps[++startCapsIndex % startCaps.length],
      );
    });
  }

  void _changePattern(PolylineId polylineId) {
    final Polyline polyline = polylines[polylineId]!;
    setState(() {
      polylines[polylineId] = polyline.copyWith(
        patternsParam: patterns[++patternsIndex % patterns.length],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    final PolylineId? selectedId = selectedPolyline;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 300.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(53.1721, -3.5402),
                zoom: 7.0,
              ),
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: _onMapCreated,
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
                        TextButton(
                          child: const Text('add'),
                          onPressed: _add,
                        ),
                        TextButton(
                          child: const Text('remove'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _remove(selectedId),
                        ),
                        TextButton(
                          child: const Text('toggle visible'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _toggleVisible(selectedId),
                        ),
                        TextButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _toggleGeodesic(selectedId),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('change width'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _changeWidth(selectedId),
                        ),
                        TextButton(
                          child: const Text('change color'),
                          onPressed: (selectedId == null)
                              ? null
                              : () => _changeColor(selectedId),
                        ),
                        TextButton(
                          child: const Text('change start cap [Android only]'),
                          onPressed: isIOS || (selectedId == null)
                              ? null
                              : () => _changeStartCap(selectedId),
                        ),
                        TextButton(
                          child: const Text('change end cap [Android only]'),
                          onPressed: isIOS || (selectedId == null)
                              ? null
                              : () => _changeEndCap(selectedId),
                        ),
                        TextButton(
                          child: const Text('change joint type [Android only]'),
                          onPressed: isIOS || (selectedId == null)
                              ? null
                              : () => _changeJointType(selectedId),
                        ),
                        TextButton(
                          child: const Text('change pattern [Android only]'),
                          onPressed: isIOS || (selectedId == null)
                              ? null
                              : () => _changePattern(selectedId),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    final double offset = _polylineIdCounter.ceilToDouble();
    points.add(_createLatLng(51.4816 + offset, -3.1791));
    points.add(_createLatLng(53.0430 + offset, -2.9925));
    points.add(_createLatLng(53.1396 + offset, -4.2739));
    points.add(_createLatLng(52.4153 + offset, -4.0829));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
