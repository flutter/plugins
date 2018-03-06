// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:google_mobile_maps/google_mobile_maps.dart';

GoogleMapsOverlayController controller1 =
    new GoogleMapsOverlayController.fromSize(300.0, 200.0);
GoogleMapsOverlayController controller2 =
    new GoogleMapsOverlayController.fromSize(300.0, 300.0);

void main() {
  runApp(new MaterialApp(
    home: new MyAppHome(),
    navigatorObservers: <NavigatorObserver>[
      controller1.overlayController,
      controller2.overlayController,
    ],
  ));
}

class MyAppHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Google Maps example'),
      ),
      body: new Center(
        child: new Card(
          child: new GoogleMapsOverlay(controller: controller1),
        ),
      ),
      floatingActionButton: new Builder(
        builder: (BuildContext actionContext) => new FloatingActionButton(
              child: new Icon(Icons.place),
              onPressed: () {
                Navigator.of(actionContext).push(
                    new MaterialPageRoute<Null>(builder: (_) => new MapPage()));
              },
            ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Another page'),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Center(child: new GoogleMapsOverlay(controller: controller2)),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new FlatButton(
                onPressed: () {
                  controller2.mapsController.moveCamera(
                    const Location(37.4231613, -122.087159),
                    const Zoom(11.0),
                  );
                },
                color: Colors.blue,
                child: const Text('Mountain View'),
              ),
              new FlatButton(
                onPressed: () {
                  controller2.mapsController.moveCamera(
                    const Location(56.1725505, 10.1850512),
                    const Zoom(11.0),
                  );
                },
                color: Colors.red,
                child: const Text('Aarhus'),
              ),
              new FlatButton(
                onPressed: () {
                  controller2.mapsController.moveCamera(
                    const Location(-33.852, 151.211),
                    const Zoom(11.0),
                  );
                },
                color: Colors.yellow,
                child: const Text('Sydney'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
