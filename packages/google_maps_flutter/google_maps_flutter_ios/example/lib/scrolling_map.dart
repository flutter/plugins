// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

const LatLng _center = LatLng(32.080664, 34.9563837);

class ScrollingMapPage extends GoogleMapExampleAppPage {
  const ScrollingMapPage({Key? key})
      : super(const Icon(Icons.map), 'Scrolling map', key: key);

  @override
  Widget build(BuildContext context) {
    return const ScrollingMapBody();
  }
}

class ScrollingMapBody extends StatelessWidget {
  const ScrollingMapBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text('This map consumes all touch events.'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _center,
                        zoom: 11.0,
                      ),
                      gestureRecognizers: //
                          <Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: Column(
              children: <Widget>[
                const Text("This map doesn't consume the vertical drags."),
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child:
                      Text('It still gets other gestures (e.g scale or tap).'),
                ),
                Center(
                  child: SizedBox(
                    width: 300.0,
                    height: 300.0,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: _center,
                        zoom: 11.0,
                      ),
                      markers: <Marker>{
                        Marker(
                          markerId: const MarkerId('test_marker_id'),
                          position: LatLng(
                            _center.latitude,
                            _center.longitude,
                          ),
                          infoWindow: const InfoWindow(
                            title: 'An interesting location',
                            snippet: '*',
                          ),
                        ),
                      },
                      gestureRecognizers: <
                          Factory<OneSequenceGestureRecognizer>>{
                        Factory<OneSequenceGestureRecognizer>(
                          () => ScaleGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
