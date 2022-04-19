// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/page.dart';

class HeatmapPage extends GoogleMapExampleAppPage {
  const HeatmapPage() : super(const Icon(Icons.map), 'Heatmaps');

  @override
  Widget build(BuildContext context) {
    return const HeatmapBody();
  }
}

class HeatmapBody extends StatefulWidget {
  const HeatmapBody();

  @override
  State<StatefulWidget> createState() => HeatmapBodyState();
}

class HeatmapBodyState extends State<HeatmapBody> {
  static const LatLng sanFrancisco = LatLng(37.774546, -122.433523);

  List<WeightedLatLng> enabledPoints = <WeightedLatLng>[
    WeightedLatLng(37.782, -122.447),
    WeightedLatLng(37.782, -122.445),
    WeightedLatLng(37.782, -122.443),
    WeightedLatLng(37.782, -122.441),
    WeightedLatLng(37.782, -122.439),
    WeightedLatLng(37.782, -122.437),
    WeightedLatLng(37.782, -122.435),
    WeightedLatLng(37.785, -122.447),
    WeightedLatLng(37.785, -122.445),
    WeightedLatLng(37.785, -122.443),
    WeightedLatLng(37.785, -122.441),
    WeightedLatLng(37.785, -122.439),
    WeightedLatLng(37.785, -122.437),
    WeightedLatLng(37.785, -122.435)
  ];

  List<WeightedLatLng> disabledPoints = <WeightedLatLng>[];

  void _addPoint() {
    if (disabledPoints.isEmpty) {
      return;
    }

    final WeightedLatLng point = disabledPoints.first;
    disabledPoints.removeAt(0);

    setState(() => enabledPoints.add(point));
  }

  void _removePoint() {
    if (enabledPoints.isEmpty) {
      return;
    }

    final WeightedLatLng point = enabledPoints.first;
    enabledPoints.removeAt(0);

    setState(() => disabledPoints.add(point));
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
                  target: sanFrancisco,
                  zoom: 13,
                ),
                heatmaps: <Heatmap>{
                  Heatmap(
                    heatmapId: const HeatmapId('test'),
                    data: enabledPoints,
                    gradient: const <Color>[
                      Color.fromARGB(0, 0, 255, 255),
                      Color.fromARGB(255, 0, 255, 255),
                      Color.fromARGB(255, 0, 191, 255),
                      Color.fromARGB(255, 0, 127, 255),
                      Color.fromARGB(255, 0, 63, 255),
                      Color.fromARGB(255, 0, 0, 255),
                      Color.fromARGB(255, 0, 0, 223),
                      Color.fromARGB(255, 0, 0, 191),
                      Color.fromARGB(255, 0, 0, 159),
                      Color.fromARGB(255, 0, 0, 127),
                      Color.fromARGB(255, 63, 0, 91),
                      Color.fromARGB(255, 127, 0, 63),
                      Color.fromARGB(255, 191, 0, 31),
                      Color.fromARGB(255, 255, 0, 0),
                    ],
                    maxIntensity: 1,
                    opacity: 0.7,
                    radius: 20,
                  )
                }),
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
                          child: const Text('Add point'),
                          onPressed:
                              disabledPoints.isNotEmpty ? _addPoint : null,
                        ),
                        TextButton(
                          child: const Text('Remove point'),
                          onPressed:
                              enabledPoints.isNotEmpty ? _removePoint : null,
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
}
