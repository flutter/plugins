// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class MoveCameraPage extends Page {
  MoveCameraPage() : super(const Icon(Icons.map), 'Camera control');

  @override
  Widget build(BuildContext context) {
    return const MoveCamera();
  }
}

class MoveCamera extends StatefulWidget {
  const MoveCamera();
  @override
  State createState() => MoveCameraState();
}

class MoveCameraState extends State<MoveCamera> {
  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Widget _button({@required String text, @required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
        color: Colors.lightBlue[700],
        textColor: Colors.white,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _newCameraPosition() {
    return _button(
      text: 'newCameraPosition',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.newCameraPosition(
            const CameraPosition(
              bearing: 270.0,
              target: LatLng(51.5160895, -0.1294527),
              tilt: 30.0,
              zoom: 17.0,
            ),
          ),
        );
      },
    );
  }

  Widget _newLatLng() {
    return _button(
      text: 'newLatLng',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.newLatLng(
            const LatLng(56.1725505, 10.1850512),
          ),
        );
      },
    );
  }

  Widget _newLatLngBounds() {
    return _button(
      text: 'newLatLngBounds',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: const LatLng(-38.483935, 113.248673),
              northeast: const LatLng(-8.982446, 153.823821),
            ),
            10.0,
          ),
        );
      },
    );
  }

  Widget _newLatLngZoom() {
    return _button(
      text: 'newLatLngZoom',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.newLatLngZoom(
            const LatLng(37.4231613, -122.087159),
            11.0,
          ),
        );
      },
    );
  }

  Widget _scrollBy() {
    return _button(
      text: 'scrollBy',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.scrollBy(150.0, -225.0),
        );
      },
    );
  }

  Widget _zoomByWithFocus() {
    return _button(
      text: 'zoomBy with focus',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.zoomBy(
            -0.5,
            const Offset(30.0, 20.0),
          ),
        );
      },
    );
  }

  Widget _zoomBy() {
    return _button(
      text: 'zoomBy',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.zoomBy(-0.5),
        );
      },
    );
  }

  Widget _zoomIn() {
    return _button(
      text: 'zoomIn',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.zoomIn(),
        );
      },
    );
  }

  Widget _zoomOut() {
    return _button(
      text: 'zoomOut',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.zoomOut(),
        );
      },
    );
  }

  Widget _zoomTo() {
    return _button(
      text: 'zoomTo',
      onPressed: () {
        mapController.moveCamera(
          CameraUpdate.zoomTo(16.0),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: SizedBox(
                width: 300.0,
                height: 200.0,
                child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    options: GoogleMapOptions.defaultOptions)),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            children: <Widget>[
              _newCameraPosition(),
              _zoomByWithFocus(),
              _newLatLng(),
              _zoomBy(),
              _newLatLngBounds(),
              _zoomIn(),
              _newLatLngZoom(),
              _zoomOut(),
              _scrollBy(),
              _zoomTo(),
            ],
          ),
        ),
      ],
    );
  }
}
