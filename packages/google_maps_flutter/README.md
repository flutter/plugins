# Google Maps for Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_flutter.svg)](https://pub.dartlang.org/packages/google_maps_flutter)

A Flutter plugin to use [Google Maps](https://developers.google.com/maps/) in
iOS and Android apps.

## Caveat

This plugin provides an *unpublished preview* of the Flutter API for Google Maps:
* Dart APIs for controlling and interacting with a GoogleMap view from Flutter
  code are still being consolidated and expanded. The intention is to grow
  current coverage into a complete offering. Issues and pull requests aimed to
  help us prioritize and speed up this effort are very welcome.
* The technique currently used for compositing GoogleMap views with Flutter
  widgets is *inherently limited* and will be replaced by a fully compositional
  [Texture](https://docs.flutter.io/flutter/widgets/Texture-class.html)-based
  approach before we publish this plugin.

  In detail: the plugin currently relies on placing platform overlays on top of
  a bitmap snapshotting widget for creating the illusion of in-line compositing
  of GoogleMap views with Flutter widgets. This works only in very limited
  situations where
  * the widget is stationary
  * the widget is drawn on top of all other widgets within bounds
  * touch events within widget bounds can be safely ignored by Flutter

  The root problem with platform overlays is that they cannot be freely composed
  with other widgets. Many workarounds can be devised to address this shortcoming
  in particular situations, but the Flutter team does not intend to support such
  work, as it would not move us forward towards our goal of a fully compositional
  GoogleMaps widget.

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

You can now instantiate a `GoogleMapOverlayController` and use it to configure
a `GoogleMapOverlay` widget. Client code will have to change once the plugin
stops using platform overlays.

Once added as an overlay, the map view can be controlled via the
`GoogleMapController` that you obtain as the `mapController` property of
the overlay controller. Client code written against the `GoogleMapController`
interface will be unaffected by the change away from platform overlays.

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  GoogleMapController.init();
  final GoogleMapOverlayController controller =
      GoogleMapOverlayController.fromSize(width: 300.0, height: 200.0);
  final Widget mapWidget = GoogleMapOverlay(controller: controller);
  runApp(MaterialApp(
    home: new Scaffold(
      appBar: AppBar(title: const Text('Google Maps demo')),
      body: MapsDemo(mapWidget, controller.mapController),
    ),
    navigatorObservers: <NavigatorObserver>[controller.overlayController],
  ));
}

class MapsDemo extends StatelessWidget {
  MapsDemo(this.mapWidget, this.controller);

  final Widget mapWidget;
  final GoogleMapController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(child: mapWidget),
          RaisedButton(
            child: const Text('Go to London'),
            onPressed: () {
              controller.animateCamera(CameraUpdate.newCameraPosition(
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
}
```

See the `example` directory for a complete sample app.
