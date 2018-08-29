# Google Maps for Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_flutter.svg)](https://pub.dartlang.org/packages/google_maps_flutter)

A Flutter plugin to use [Google Maps](https://developers.google.com/maps/).

## Caveat

This plugin provides an *unpublished preview* of the Flutter API for Google Maps:
* Dart APIs for controlling and interacting with a GoogleMap view from Flutter
  code are still being consolidated and expanded. The intention is to grow
  current coverage into a complete offering. Issues and pull requests aimed to
  help us prioritize and speed up this effort are very welcome.
* Currently the plugin only supports Android as it embeds a platform view in the
  Flutter hierarchy which is currently only supported for Android ([tracking
  issue](https://github.com/flutter/flutter/issues/19030)).

## Usage

To use this plugin, add
```yaml
 google_maps_flutter:
   git:
     url: git://github.com/flutter/plugins
     path: packages/google_maps_flutter
```
as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

Get an API key at <https://cloud.google.com/maps-platform/>.

### Android

Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

Supply your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSServices provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

### Both

You can now add a `GoogleMap` widget to your widget tree.

The map view can be controlled with the `GoogleMapController` that is passed to
the `GoogleMap`'s `onMapCreated` callback.

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: new Scaffold(
      appBar: AppBar(title: const Text('Google Maps demo')),
      body: MapsDemo(),
    ),
  ));
}

class MapsDemo extends StatefulWidget {
  @override
  State createState() => MapsDemoState();
}

class MapsDemoState extends State<MapsDemo> {

  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 300.0,
              height: 200.0,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
              ),
            ),
          ),
          RaisedButton(
            child: const Text('Go to London'),
            onPressed: mapController == null ? null : () {
              mapController.animateCamera(CameraUpdate.newCameraPosition(
                const CameraPosition(
                  bearing: 270.0,
                  target: LatLng(51.5160895, -0.1294527),
                  tilt: 30.0,
                  zoom: 17.0,
                ),
              ));
            },
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() { mapController = controller; });
  }
}
```

See the `example` directory for a complete sample app.
