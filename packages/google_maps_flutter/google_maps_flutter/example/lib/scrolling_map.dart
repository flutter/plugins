// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class ScrollingMapPage extends Page {
  ScrollingMapPage() : super(const Icon(Icons.map), 'Scrolling map');

  @override
  Widget build(BuildContext context) {
    return const ScrollingMapBody();
  }
}

class ScrollingMapBody extends StatelessWidget {
  const ScrollingMapBody();

  final LatLng center = const LatLng(32.080664, 34.9563837);

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
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 11.0,
                      ),
                      gestureRecognizers:
                          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                          // https://github.com/flutter/flutter/issues/28312
                          // ignore: prefer_collection_literals
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                        ),
                      ].toSet(),
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
                const Text('This map doesn\'t consume the vertical drags.'),
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
                      initialCameraPosition: CameraPosition(
                        target: center,
                        zoom: 11.0,
                      ),
                      markers:
                          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                          // https://github.com/flutter/flutter/issues/28312
                          // ignore: prefer_collection_literals
                          Set<Marker>.of(
                        <Marker>[
                          Marker(
                            markerId: MarkerId("test_marker_id"),
                            position: LatLng(
                              center.latitude,
                              center.longitude,
                            ),
                            infoWindow: const InfoWindow(
                              title: 'An interesting location',
                              snippet: '*',
                            ),
                          )
                        ],
                      ),
                      gestureRecognizers:
                          // TODO(iskakaushik): Remove this when collection literals makes it to stable.
                          // https://github.com/flutter/flutter/issues/28312
                          // ignore: prefer_collection_literals
                          <Factory<OneSequenceGestureRecognizer>>[
                        Factory<OneSequenceGestureRecognizer>(
                          () => ScaleGestureRecognizer(),
                        ),
                      ].toSet(),
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
