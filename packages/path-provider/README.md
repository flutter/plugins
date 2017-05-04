# path_provider

A Flutter plugin for finding commonly used locations on the filesystem. Supports iOS and Android.


## Usage

To use this plugin, add path_provider as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).


### Example
After importing ```'package:path_provider/path_provider.dart'``` the directories can be queried as follows

``` dart
Directory tempDir = await getTemporaryDirectory();
String tempPath = tempDir.path;

Directory appDocDir = await getApplicationDocumentsDirectory();
String appDocPath = appDocDir.path;
```

Please see the example app of this plugin for a full example.
