# wifi_info_flutter

---

## Deprecation Notice

This plugin has been replaced by the [Flutter Community Plus
Plugins](https://plus.fluttercommunity.dev/) version,
[`network_info_plus`](https://pub.dev/packages/network_info_plus).
No further updates are planned to this plugin, and we encourage all users to
migrate to the Plus version.

Critical fixes (e.g., for any security incidents) will be provided through the
end of 2021, at which point this package will be marked as discontinued.

---

This plugin retrieves information about a device's connection to wifi.

> Note that on Android, this does not guarantee connection to Internet. For instance,
the app might have wifi access but it might be a VPN or a hotel WiFi with no access.

## Usage

### Android

Sample usage to check current status:

To successfully get WiFi Name or Wi-Fi BSSID starting with Android O, ensure all of the following conditions are met:

 * If your app is targeting Android 10 (API level 29) SDK or higher, your app has the ACCESS_FINE_LOCATION permission.

 * If your app is targeting SDK lower than Android 10 (API level 29), your app has the ACCESS_COARSE_LOCATION or ACCESS_FINE_LOCATION permission.

 * Location services are enabled on the device (under Settings > Location).

You can get wi-fi related information using:

```dart
import 'package:wifi_info_flutter/wifi_info_flutter.dart';

var wifiBSSID = await WifiInfo().getWifiBSSID();
var wifiIP = await WifiInfo().getWifiIP();
var wifiName = await WifiInfo().getWifiName();
```

### iOS 12

To use `.getWifiBSSID()` and `.getWifiName()` on iOS >= 12, the `Access WiFi information capability` in XCode must be enabled. Otherwise, both methods will return null.

### iOS 13

The methods `.getWifiBSSID()` and `.getWifiName()` utilize the [`CNCopyCurrentNetworkInfo`](https://developer.apple.com/documentation/systemconfiguration/1614126-cncopycurrentnetworkinfo) function on iOS.

As of iOS 13, Apple announced that these APIs will no longer return valid information.
An app linked against iOS 12 or earlier receives pseudo-values such as:

 * SSID: "Wi-Fi" or "WLAN" ("WLAN" will be returned for the China SKU).

 * BSSID: "00:00:00:00:00:00"

An app linked against iOS 13 or later receives `null`.

The `CNCopyCurrentNetworkInfo` will work for Apps that:

  * The app uses Core Location, and has the user’s authorization to use location information.

  * The app uses the NEHotspotConfiguration API to configure the current Wi-Fi network.

  * The app has active VPN configurations installed.

If your app falls into the last two categories, it will work as it is. If your app doesn't fall into the last two categories,
and you still need to access the wifi information, you should request user's authorization to use location information.

There is a helper method provided in this plugin to request the location authorization: `requestLocationServiceAuthorization`.
To request location authorization, make sure to add the following keys to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

* `NSLocationAlwaysAndWhenInUseUsageDescription` - describe why the app needs access to the user’s location information all the time (foreground and background). This is called _Privacy - Location Always and When In Use Usage Description_ in the visual editor.
* `NSLocationWhenInUseUsageDescription` - describe why the app needs access to the user’s location information when the app is running in the foreground. This is called _Privacy - Location When In Use Usage Description_ in the visual editor.

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
