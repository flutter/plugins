# connectivity

This plugin allows Flutter apps to discover network connectivity and configure
themselves accordingly. It can distinguish between cellular vs WiFi connection.
This plugin works for iOS and Android.

> Note that on Android, this does not guarantee connection to Internet. For instance,
the app might have wifi access but it might be a VPN or a hotel WiFi with no access.

Sample usage:

```dart
import 'package:connectivity/connectivity.dart' as connectivity;

var connectivityResult = await connectivity.checkConnectivity();
if (connectivityResult == ConnectivityResult.mobile) {
  // I am connected to a mobile network.
} else if (connectivityResult == ConnectivityResult.wifi) {
  // I am connected to a wifi network.
}
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
