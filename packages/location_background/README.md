# Flutter Background Execution Sample - LocationBackgroundPlugin

An example Flutter plugin that showcases background execution using iOS location services.

## Getting Started

**_NOTE: This plugin does not currently have an Android implementation._**

To import, add the following to your Dart file:

```dart
import 'package:location_background/location_background.dart';
```

Example usage:

```dart
import 'package:location_background/location_background.dart';

final locationManager = LocationBackgroundPlugin();

void locationUpdateCallback(Location location) {
  print('Location Update: $location');
}

Future<void> startMonitoringLocationChanges() =>
    locationManager.monitorSignificantLocationChanges(locationUpdateCallback);
    
Future<void> stopMonitoringLocationChanges() =>
    locationManager.cancelLocationUpdates();
```

**WARNING:** do not maintain volatile state or perform long running operations in the location update callback. There is no guarantee from the system for how long a process can perform background processing after a location update, and the Dart isolate may shutdown during execution at the request of the system.

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
