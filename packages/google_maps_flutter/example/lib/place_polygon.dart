// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlacePolygonPage extends Page {
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
  int _polygonIdCounter = 1;
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
    _polygonIdCounter++;
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
                        FlatButton(
                          child: const Text('add'),
                          onPressed: _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (selectedPolygon == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (selectedPolygon == null) ? null : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : _toggleGeodesic,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change stroke width'),
                          onPressed:
                              (selectedPolygon == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change stroke color'),
                          onPressed: (selectedPolygon == null)
                              ? null
                              : _changeStrokeColor,
                        ),
                        FlatButton(
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

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
