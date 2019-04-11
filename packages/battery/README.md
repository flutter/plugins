# Battery

[![pub package](https://img.shields.io/pub/v/battery.svg)](https://pub.dartlang.org/packages/battery)

A Flutter plugin to access various information about the battery of the device the app is running on.

## Usage
To use this plugin, add `battery` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
// Import package
import 'package:battery/battery.dart';

// Instantiate it
var battery = Battery();

// Access current battery level
print(await battery.batteryLevel);

// Be informed when the state (full, charging, discharging) changes
_battery.onBatteryStateChanged.listen((BatteryState state) {
  // Do something with new state
});
```
