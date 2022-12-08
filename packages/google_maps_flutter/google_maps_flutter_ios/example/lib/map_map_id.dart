// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';

class MapIdPage extends GoogleMapExampleAppPage {
  const MapIdPage({Key? key})
      : super(const Icon(Icons.map), 'Cloud-based maps styling', key: key);

  @override
  Widget build(BuildContext context) {
    return const MapIdBody();
  }
}

class MapIdBody extends StatefulWidget {
  const MapIdBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapIdBodyState();
}

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

class MapIdBodyState extends State<MapIdBody> {
  ExampleGoogleMapController? controller;

  Key _key = const Key('mapId#');
  String? _mapId;
  final TextEditingController _mapIdController = TextEditingController();

  void _setMapId() {
    setState(() {
      _mapId = _mapIdController.text;

      // Change key to initialize new map instance for new mapId.
      _key = Key(_mapId ?? 'mapId#');
    });
  }

  @override
  Widget build(BuildContext context) {
    final ExampleGoogleMap googleMap = ExampleGoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _kMapCenter,
        zoom: 7.0,
      ),
      key: _key,
      cloudMapId: _mapId,
    );

    final List<Widget> columnChildren = <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: googleMap,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          controller: _mapIdController,
          decoration: const InputDecoration(
            hintText: 'Map Id',
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: ElevatedButton(
          onPressed: () => _setMapId(),
          child: const Text(
            'Press to use specified map Id',
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(10.0),
        child:
            Text('On iOS, cloud based map styling works only if iOS platform '
                'version 12 or above is targeted in project Podfile. '
                "Run command 'pod update GoogleMaps' to update plugin"),
      )
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  @override
  void dispose() {
    _mapIdController.dispose();
    super.dispose();
  }

  void _onMapCreated(ExampleGoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }
}
