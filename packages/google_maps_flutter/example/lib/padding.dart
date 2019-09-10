// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'page.dart';

class PaddingPage extends Page {
  PaddingPage() : super(const Icon(Icons.map), 'Add padding to the map');

  @override
  Widget build(BuildContext context) {
    return const MarkerIconsBody();
  }
}

class MarkerIconsBody extends StatefulWidget {
  const MarkerIconsBody();

  @override
  State<StatefulWidget> createState() => MarkerIconsBodyState();
}

const LatLng _kMapCenter = LatLng(52.4478, -3.5402);

class MarkerIconsBodyState extends State<MarkerIconsBody> {
  GoogleMapController controller;

  EdgeInsets _padding = const EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final GoogleMap googleMap = GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: const CameraPosition(
        target: _kMapCenter,
        zoom: 7.0,
      ),
      padding: _padding,
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
        padding: const EdgeInsets.only(top: 20),
        child: Center(
          child: Text(
            "Enter Padding Below",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];

    columnChildren.addAll(<Widget>[_paddingInput(), _buttons()]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  void _onMapCreated(GoogleMapController controllerParam) {
    setState(() {
      controller = controllerParam;
    });
  }

  TextEditingController _topController = TextEditingController();
  TextEditingController _bottomController = TextEditingController();
  TextEditingController _leftController = TextEditingController();
  TextEditingController _rightController = TextEditingController();

  Widget _paddingInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 2,
            child: TextField(
              controller: _topController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Top",
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 2,
            child: TextField(
              controller: _bottomController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Bottom",
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 2,
            child: TextField(
              controller: _leftController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Left",
              ),
            ),
          ),
          Spacer(),
          Flexible(
            flex: 2,
            child: TextField(
              controller: _rightController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Right",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FlatButton(
            child: const Text("Set Padding"),
            onPressed: () {
              setState(() {
                _padding = EdgeInsets.fromLTRB(
                    double.tryParse(_leftController.value?.text) ?? 0,
                    double.tryParse(_topController.value?.text) ?? 0,
                    double.tryParse(_rightController.value?.text) ?? 0,
                    double.tryParse(_bottomController.value?.text) ?? 0);
              });
            },
          ),
          FlatButton(
            child: const Text("Reset Padding"),
            onPressed: () {
              setState(() {
                _topController.clear();
                _bottomController.clear();
                _leftController.clear();
                _rightController.clear();
                _padding = const EdgeInsets.all(0);
              });
            },
          )
        ],
      ),
    );
  }
}
