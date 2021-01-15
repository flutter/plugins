// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlacePolygonPage extends GoogleMapExampleAppPage {
  PlacePolygonPage() : super(const Icon(Icons.linear_scale), 'Place polygon');

  @override
  Widget build(BuildContext context) {
    return const PlacePolygonBody();
  }
}

class PlacePolygonBody extends StatefulWidget {
  const PlacePolygonBody();

  @override
  State<StatefulWidget> createState() => PlacePolygonBodyState();
}

class PlacePolygonBodyState extends State<PlacePolygonBody> {
  PlacePolygonBodyState();

  GoogleMapController controller;
  Map<PolygonId, Polygon> polygons = <PolygonId, Polygon>{};
  Map<PolygonId, double> polygonOffsets = <PolygonId, double>{};
  int _polygonIdCounter = 0;
  PolygonId selectedPolygon;

  // Values when toggling polygon color
  int strokeColorsIndex = 0;
  int fillColorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
  ];

  // Values when toggling polygon width
  int widthsIndex = 0;
  List<int> widths = <int>[10, 20, 5];

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolygonTapped(PolygonId polygonId) {
    setState(() {
      selectedPolygon = polygonId;
    });
  }

  void _remove() {
    setState(() {
      if (polygons.containsKey(selectedPolygon)) {
        polygons.remove(selectedPolygon);
      }
      selectedPolygon = null;
    });
  }

  void _add() {
    final int polygonCount = polygons.length;

    if (polygonCount == 12) {
      return;
    }

    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    final PolygonId polygonId = PolygonId(polygonIdVal);

    final Polygon polygon = Polygon(
      polygonId: polygonId,
      consumeTapEvents: true,
      strokeColor: Colors.orange,
      strokeWidth: 5,
      fillColor: Colors.green,
      points: _createPoints(),
      onTap: () {
        _onPolygonTapped(polygonId);
      },
    );

    setState(() {
      polygons[polygonId] = polygon;
      polygonOffsets[polygonId] = _polygonIdCounter.ceilToDouble();
      // increment _polygonIdCounter to have unique polygon id each time
      _polygonIdCounter++;
    });
  }

  void _toggleGeodesic() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        geodesicParam: !polygon.geodesic,
      );
    });
  }

  void _toggleVisible() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        visibleParam: !polygon.visible,
      );
    });
  }

  void _changeStrokeColor() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        strokeColorParam: colors[++strokeColorsIndex % colors.length],
      );
    });
  }

  void _changeFillColor() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        fillColorParam: colors[++fillColorsIndex % colors.length],
      );
    });
  }

  void _changeWidth() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        strokeWidthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  void _addHoles() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(holesParam: _createHoles());
    });
  }

  void _removeHoles() {
    final Polygon polygon = polygons[selectedPolygon];
    setState(() {
      polygons[selectedPolygon] = polygon.copyWith(
        holesParam: <List<LatLng>>[],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                target: LatLng(52.4478, -3.5402),
                zoom: 7.0,
              ),
              polygons: Set<Polygon>.of(polygons.values),
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
                          onPressed: (selectedPolygon == null) ? null : _remove,
                        ),
                        TextButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (selectedPolygon == null) ? null : _toggleVisible,
                        ),
                        TextButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : _toggleGeodesic,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        TextButton(
                          child: const Text('add holes'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : ((polygons[selectedPolygon].holes.isNotEmpty)
                                  ? null
                                  : _addHoles),
                        ),
                        TextButton(
                          child: const Text('remove holes'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : ((polygons[selectedPolygon].holes.isEmpty)
                                  ? null
                                  : _removeHoles),
                        ),
                        TextButton(
                          child: const Text('change stroke width'),
                          onPressed:
                              (selectedPolygon == null) ? null : _changeWidth,
                        ),
                        TextButton(
                          child: const Text('change stroke color'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : _changeStrokeColor,
                        ),
                        TextButton(
                          child: const Text('change fill color'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : _changeFillColor,
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
    final double offset = _polygonIdCounter.ceilToDouble();
    points.add(_createLatLng(51.2395 + offset, -3.4314));
    points.add(_createLatLng(53.5234 + offset, -3.5314));
    points.add(_createLatLng(52.4351 + offset, -4.5235));
    points.add(_createLatLng(52.1231 + offset, -5.0829));
    return points;
  }

  List<List<LatLng>> _createHoles() {
    final List<List<LatLng>> holes = <List<LatLng>>[];
    final double offset = polygonOffsets[selectedPolygon];

    final List<LatLng> hole1 = <LatLng>[];
    hole1.add(_createLatLng(51.8395 + offset, -3.8814));
    hole1.add(_createLatLng(52.0234 + offset, -3.9914));
    hole1.add(_createLatLng(52.1351 + offset, -4.4435));
    hole1.add(_createLatLng(52.0231 + offset, -4.5829));
    holes.add(hole1);

    final List<LatLng> hole2 = <LatLng>[];
    hole2.add(_createLatLng(52.2395 + offset, -3.6814));
    hole2.add(_createLatLng(52.4234 + offset, -3.7914));
    hole2.add(_createLatLng(52.5351 + offset, -4.2435));
    hole2.add(_createLatLng(52.4231 + offset, -4.3829));
    holes.add(hole2);

    return holes;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
