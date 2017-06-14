# sensors

A Flutter plugin to access the accelerometer and gyroscope sensors.


## Usage

To use this plugin, add `sensors` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


### Example

``` dart

import 'package:sensors/sensors.dart';

accelerometerEvents.listen((List<double> values) {
 // Do something with the values;
};)

gyroscopeEvents.listen((List<double> values) {
 // Do something with the values;
};)
```