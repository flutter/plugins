// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

// #docregion SampleUsage
import 'package:flutter/material.dart';
import 'package:google_maps_places/google_maps_places.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Places Demo',
      home: PlacesSample(),
    );
  }
}

class PlacesSample extends StatefulWidget {
  const PlacesSample({super.key});
  @override
  State<PlacesSample> createState() => PlacesSampleState();
}

class PlacesSampleState extends State<PlacesSample> {
  final String _query = 'Hospital';
  final List<String> _countries = <String>['fi'];
  final TypeFilter _typeFilter = TypeFilter.address;

  final LatLng _origin = const LatLng(65.0121, 25.4651);

  final LatLngBounds _locationBias = LatLngBounds(
    southwest: const LatLng(60.4518, 22.2666),
    northeast: const LatLng(70.0821, 27.8718),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _findPlaces,
          child: const Text('Find'),
        ),
      ),
    );
  }

  Future<void> _findPlaces() async {
    final List<AutocompletePrediction> result =
        await GoogleMapsPlaces.findAutocompletePredictions(
            query: _query,
            countries: _countries,
            typeFilter: <TypeFilter>[_typeFilter],
            origin: _origin,
            locationBias: _locationBias);
    print('Results: $result');
  }
}
// #enddocregion SampleUsage
