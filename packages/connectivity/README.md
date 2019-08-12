# connectivity

This plugin allows Flutter apps to discover network connectivity and configure
themselves accordingly. It can distinguish between cellular vs WiFi connection.
This plugin works for iOS and Android.

> Note that on Android, this does not guarantee connection to Internet. For instance,
the app might have wifi access but it might be a VPN or a hotel WiFi with no access.

## Usage

Sample usage to check current status:

```dart
import 'package:connectivity/connectivity.dart';

var connectivityInfo = await (Connectivity().checkConnectivityInfo());
if (connectivityInfo.result == ConnectivityResult.mobile) {
  // I am connected to a mobile network.
  if(connectivityInfo.subtype == ConnectionSubtype.HSDPA){
    // I am on an HSDPA network
  }
} else if (connectivityInfo.result == ConnectivityResult.wifi) {
  // I am connected to a wifi network.
}
```

You can also check for a connection type when you are on mobile:

```dart
import 'package:connectivity/connectivity.dart';

var connectivityResult = await (Connectivity().getNetworkSubtype());

if(connectivityResult.subtype == ConnectionSubtype.edge){
  // I am on an edge network
} else if(connectivityResult.subtype == ConnectionSubtype.hsdpa){
  // I am on a hsdpa network
} else if(connectivityResult.subtype == ConnectionSubtype.lte){
  // I am on an lte network
}
```

> Note that you should not be using the current network status for deciding
whether you can reliably make a network connection. Always guard your app code
against timeouts and errors that might come from the network layer.

You can also listen for network state changes by subscribing to the stream
exposed by connectivity plugin:

```dart
import 'package:connectivity/connectivity.dart';

@override
initState() {
  super.initState();

  subscription = Connectivity().onConnectivityInfoChanged.listen((ConnectionInfo info) {
    // Got a new connectivity status!
    info.result = // ConnectivityResult info
    info.subtype = // Mobile Connectivity Subtype info
  });
}

// Be sure to cancel subscription after you are done
@override
dispose() {
  super.dispose();

  subscription.cancel();
}
```

You can get WIFI related information using:

```dart
import 'package:connectivity/connectivity.dart';

var wifiBSSID = await (Connectivity().getWifiBSSID());
var wifiIP = await (Connectivity().getWifiIP());network
var wifiName = await (Connectivity().getWifiName());wifi network
```

### Known Issues

#### iOS 13

The methods `.getWifiBSSID()` and `.getWifiName()` utilize the [CNCopyCurrentNetworkInfo](https://developer.apple.com/documentation/systemconfiguration/1614126-cncopycurrentnetworkinfo) function on iOS.

As of iOS 13, Apple announced that these APIs will no longer return valid information by default and will instead return the following:
> SSID: "Wi-Fi" or "WLAN" ("WLAN" will be returned for the China SKU)  
> BSSID: "00:00:00:00:00:00"

You can follow issue [#37804](https://github.com/flutter/flutter/issues/37804) for the changes required to return valid SSID and BSSID values with iOS 13.

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
