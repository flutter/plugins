# Battery

**Please set your constraint to `battery: '>=0.3.y+x <2.0.0'`**

## Backward compatible 1.0.0 version is coming
The battery plugin has reached a stable API, we guarantee that version `1.0.0` will be backward compatible with `0.3.y+z`.
Please use `battery: '>=0.3.y+x <2.0.0'` as your dependency constraint to allow a smoother ecosystem migration.
For more details see: https://github.com/flutter/flutter/wiki/Package-migration-to-1.0.0

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
