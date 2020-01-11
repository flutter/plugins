// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceHeatmapPage extends Page {
  PlaceHeatmapPage() : super(const Icon(Icons.linear_scale), 'Place heatmap');

  @override
  Widget build(BuildContext context) {
    return const PlaceHeatmapBody();
  }
}

class PlaceHeatmapBody extends StatefulWidget {
  const PlaceHeatmapBody();

  @override
  State<StatefulWidget> createState() => PlaceHeatmapBodyState();
}

class PlaceHeatmapBodyState extends State<PlaceHeatmapBody> {
  PlaceHeatmapBodyState();

  GoogleMapController controller;
  Map<HeatmapId, Heatmap> heatmaps = <HeatmapId, Heatmap>{};
  int _heatmapIdCounter = 1;
  HeatmapId currentHeatmap;

  // Values when changing heatmap gradient.
  int gradientsIndex = 0;
  List<HeatmapGradient> gradients = <HeatmapGradient>[
    HeatmapGradient(
        colors: <Color>[Colors.green, Colors.red],
        startPoints: <double>[0.2, 0.7]),
    HeatmapGradient(
        colors: <Color>[Colors.green, Colors.red],
        startPoints: <double>[0.8, 0.9]),
    HeatmapGradient(
        colors: <Color>[Colors.green, Colors.red],
        startPoints: <double>[0.2, 0.7],
        colorMapSize: 8),
    HeatmapGradient(
        colors: <Color>[Colors.blue, Colors.purple],
        startPoints: <double>[0.2, 0.7]),
  ];

  // Values when changing heatmap opacity.
  int opacitiesIndex = 0;
  List<double> opacities = <double>[0.7, 0.3, 1.0];

  // Values when changing heatmap radius.
  int radiiIndex = 0;
  List<int> radii = <int>[20, 10, 30, 40, 50];

  // Values when changing heatmap layer transparency.
  int transparenciesIndex = 0;
  List<double> transparencies = <double>[1.0, 0.75, 0.5, 0.25];

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _remove() {
    setState(() {
      if (heatmaps.containsKey(currentHeatmap)) {
        heatmaps.remove(currentHeatmap);
      }
      currentHeatmap = null;
    });
  }

  void _add() {
    final int heatmapCount = heatmaps.length;

    if (heatmapCount == 1) {
      return;
    }

    final String heatmapIdVal = 'heatmap_id_$_heatmapIdCounter';
    _heatmapIdCounter++;
    final HeatmapId heatmapId = HeatmapId(heatmapIdVal);

    final Heatmap heatmap = Heatmap(
      heatmapId: heatmapId,
      points: _createPoints(),
    );

    setState(() {
      heatmaps[heatmapId] = heatmap;
      currentHeatmap = heatmapId;
    });
  }

  void _changeGradient() {
    final Heatmap heatmap = heatmaps[currentHeatmap];
    setState(() {
      heatmaps[currentHeatmap] = heatmap.copyWith(
        gradientParam: gradients[++gradientsIndex % gradients.length],
      );
    });
  }

  void _changeOpacity() {
    final Heatmap heatmap = heatmaps[currentHeatmap];
    setState(() {
      heatmaps[currentHeatmap] = heatmap.copyWith(
        opacityParam: opacities[++opacitiesIndex % opacities.length],
      );
    });
  }

  void _changeRadius() {
    final Heatmap heatmap = heatmaps[currentHeatmap];
    setState(() {
      heatmaps[currentHeatmap] = heatmap.copyWith(
        radiusParam: radii[++radiiIndex % radii.length],
      );
    });
  }

  void _changeTransparency() {
    final Heatmap heatmap = heatmaps[currentHeatmap];
    setState(() {
      heatmaps[currentHeatmap] = heatmap.copyWith(
        transparencyParam:
            transparencies[++transparenciesIndex % transparencies.length],
      );
    });
  }

  void _toggleVisible() {
    final Heatmap heatmap = heatmaps[currentHeatmap];
    setState(() {
      heatmaps[currentHeatmap] = heatmap.copyWith(
        visibleParam: !heatmap.visible,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool iOSorNotSelected = Platform.isIOS || (currentHeatmap == null);

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
              heatmaps: Set<Heatmap>.of(heatmaps.values),
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
                          onPressed: (currentHeatmap == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (currentHeatmap == null) ? null : _toggleVisible,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change gradient'),
                          onPressed:
                              (currentHeatmap == null) ? null : _changeGradient,
                        ),
                        FlatButton(
                          child: const Text('change opacity'),
                          onPressed:
                              (currentHeatmap == null) ? null : _changeOpacity,
                        ),
                        FlatButton(
                          child: const Text('change radius'),
                          onPressed:
                              (currentHeatmap == null) ? null : _changeRadius,
                        ),
                        FlatButton(
                          child: const Text(
                              'change transparencies [android only]'),
                          onPressed:
                              iOSorNotSelected ? null : _changeTransparency,
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

  List<WeightedLatLng> _createPoints() {
    final List<WeightedLatLng> points = <WeightedLatLng>[];
    final double offset = _heatmapIdCounter.ceilToDouble();
    points.add(_createWeightedLatLng(51.4816 + offset, -3.1791, 1));
    points.add(_createWeightedLatLng(53.0430 + offset, -2.9925, 1));
    points.add(_createWeightedLatLng(53.1396 + offset, -4.2739, 1));
    points.add(_createWeightedLatLng(52.4153 + offset, -4.0829, 1));
    return points;
  }

  WeightedLatLng _createWeightedLatLng(double lat, double lng, int weight) {
    return WeightedLatLng(point: LatLng(lat, lng), intensity: weight);
  }
}
