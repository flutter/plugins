// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';

class ClusteringPage extends GoogleMapExampleAppPage {
  const ClusteringPage({Key? key})
      : super(const Icon(Icons.place), 'Manage clustering', key: key);

  @override
  Widget build(BuildContext context) {
    return const ClusteringBody();
  }
}

class ClusteringBody extends StatefulWidget {
  const ClusteringBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ClusteringBodyState();
}

typedef MarkerUpdateAction = Marker Function(Marker marker);

class ClusteringBodyState extends State<ClusteringBody> {
  ClusteringBodyState();
  static const LatLng center = LatLng(-33.86711, 151.1547171);
  static const double _scaleFactor = 0.05;

  ExampleGoogleMapController? controller;
  Map<ClusterManagerId, ClusterManager> clusterManagers =
      <ClusterManagerId, ClusterManager>{};
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _clusterManagerIdCounter = 1;
  int _markerIdCounter = 1;
  Cluster? lastCluster;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(ExampleGoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;
      });
    }
  }

  void _addClusterManager() {
    final int clusterManagerCount = clusterManagers.length;

    if (clusterManagerCount == 3) {
      return;
    }

    final String clusterManagerIdVal =
        'cluster_manager_id_$_clusterManagerIdCounter';
    _clusterManagerIdCounter++;
    final ClusterManagerId clusterManagerId =
        ClusterManagerId(clusterManagerIdVal);

    final ClusterManager clusterManager = ClusterManager(
      clusterManagerId: clusterManagerId,
      onClusterTap: (Cluster cluster) => setState(() {
        lastCluster = cluster;
      }),
    );

    setState(() {
      clusterManagers[clusterManagerId] = clusterManager;
    });
    _addMarkersToCluster(clusterManager);
  }

  void _removeClusterManager(ClusterManager clusterManager) {
    setState(() {
      // Remove markers managed by cluster manager to be removed.
      markers.removeWhere((MarkerId key, Marker marker) =>
          marker.clusterManagerId == clusterManager.clusterManagerId);
      // Remove cluster manager.
      clusterManagers.remove(clusterManager.clusterManagerId);
    });
  }

  void _addMarkersToCluster(ClusterManager clusterManager) {
    for (int i = 0; i < 15; i++) {
      final String markerIdVal =
          '${clusterManager.clusterManagerId.value}_marker_id_$_markerIdCounter';
      _markerIdCounter++;
      final MarkerId markerId = MarkerId(markerIdVal);

      final int clusterManagerIndex =
          clusterManagers.values.toList().indexOf(clusterManager);
      final Marker marker = Marker(
        clusterManagerId: clusterManager.clusterManagerId,
        markerId: markerId,
        position: LatLng(
          center.latitude + _getRandomOffset(),
          center.longitude +
              _getRandomOffset() +
              clusterManagerIndex * _scaleFactor * 2,
        ),
        infoWindow: InfoWindow(title: markerIdVal, snippet: '*'),
        onTap: () => _onMarkerTapped(markerId),
      );
      markers[markerId] = marker;
    }
    setState(() {});
  }

  double _getRandomOffset() {
    return (Random().nextDouble() - 0.5) * _scaleFactor;
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }

  void _changeMarkersRotation() {
    for (final MarkerId markerId in markers.keys) {
      final Marker marker = markers[markerId]!;
      final double current = marker.rotation;
      markers[markerId] = marker.copyWith(
        rotationParam: current == 315.0 ? 0.0 : current + 45.0,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final MarkerId? selectedId = selectedMarker;
    return Stack(children: <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: ExampleGoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.852, 151.211),
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(markers.values),
              clusterManagers: Set<ClusterManager>.of(clusterManagers.values),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: () => _addClusterManager(),
                child: const Text('Add cluster manager'),
              ),
              TextButton(
                onPressed: clusterManagers.isEmpty
                    ? null
                    : () => _removeClusterManager(clusterManagers.values.last),
                child: const Text('Remove cluster manager'),
              ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              for (final MapEntry<ClusterManagerId, ClusterManager> clusterEntry
                  in clusterManagers.entries)
                TextButton(
                  onPressed: () => _addMarkersToCluster(clusterEntry.value),
                  child: Text('Add markers to ${clusterEntry.key.value}'),
                ),
            ],
          ),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: <Widget>[
              TextButton(
                onPressed: selectedId == null
                    ? null
                    : () {
                        _remove(selectedId);
                        setState(() {
                          selectedMarker = null;
                        });
                      },
                child: const Text('Remove selected marker'),
              ),
              TextButton(
                onPressed:
                    markers.isEmpty ? null : () => _changeMarkersRotation(),
                child: const Text('Change all markers rotation'),
              ),
            ],
          ),
          if (lastCluster != null)
            Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                    'Cluster with ${lastCluster!.count} markers clicked at ${lastCluster!.position}')),
        ],
      ),
    ]);
  }
}
