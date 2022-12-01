# Google Maps Places for Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_places.svg)](https://pub.dev/packages/google_maps_places)

A Flutter plugin that provides a [Google Maps Places](https://developers.google.com/maps/documentation/places/android-sdk) widget.

|             | Android | iOS    |
| ----------- | ------- | ------ |
| **Support** | SDK 20+ | iOS 9+ |

## Usage

To use this plugin, add `google_maps_places` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).

## Getting Started

- Get an API key at <https://cloud.google.com/maps-platform/>.

- Enable Google Map SDK for each platform.
  - Go to [Google Developers Console](https://console.cloud.google.com/).
  - Choose the project that you want to enable Google Maps on.
  - Select the navigation menu and then select "Google Maps".
  - Select "APIs" under the Google Maps menu.
  - To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE".
  - To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".
  - Make sure the APIs you enabled are under the "Enabled APIs" section.

For more details, see [Getting started with Google Maps Places](https://developers.google.com/maps/documentation/places/android-sdk/cloud-setup).

### Android

1. Set the `minSdkVersion` in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 20
    }
}
```

This means that app will only be available for users that run Android SDK 20 or higher.

2. Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```

### iOS

To set up, specify your API key in the application delegate `ios/Runner/AppDelegate.m`:

```objectivec
#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
@import GooglePlaces;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GMSPlacesClient provideAPIKey:@"YOUR KEY HERE"];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
@end
```

Or in your swift code, specify your API key in the application delegate `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GooglePlaces

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GooglePlaces.provideAPIKey("YOUR KEY HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Sample Usage

```dart
import 'package:flutter/material.dart';
import 'package:google_maps_places/google_maps_places.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Places Demo',
      home: PlacesSample(),
    );
  }
}

class PlacesSample extends StatefulWidget {
  @override
  State<PlacesSample> createState() => PlacesSampleState();
}

class PlacesSampleState extends State<PlacesSample> {
  String _query = 'Hospital';
  List<String> _countries = <String>['fi'];
  TypeFilter _typeFilter = TypeFilter.address;

  final LatLng _origin = const LatLng(65.0121, 25.4651);

  final LatLngBounds _locationBias = LatLngBounds(
    southwest: const LatLng(60.4518, 22.2666),
    northeast: const LatLng(70.0821, 27.8718),
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
```

See the `example` directory for a complete sample app.
