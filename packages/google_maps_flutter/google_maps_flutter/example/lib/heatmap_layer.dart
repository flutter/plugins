// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_example/page.dart';

class HeatmapLayerPage extends GoogleMapExampleAppPage {
  const HeatmapLayerPage() : super(const Icon(Icons.map), 'Heatmap layer');

  @override
  Widget build(BuildContext context) {
    return const HeatmapLayerBody();
  }
}

class HeatmapLayerBody extends StatefulWidget {
  const HeatmapLayerBody();

  @override
  State<StatefulWidget> createState() => HeatmapLayerBodyState();
}

class HeatmapLayerBodyState extends State<HeatmapLayerBody> {
  static const LatLng sanFrancisco = LatLng(37.774546, -122.433523);

  List<WeightedLatLng> disabledPoints = <WeightedLatLng>[
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

  List<WeightedLatLng> enabledPoints = <WeightedLatLng>[];

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
                heatmapLayers: <HeatmapLayer>{
                  HeatmapLayer(
                    heatmapLayerId: const HeatmapLayerId('test'),
                    data: enabledPoints,
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
