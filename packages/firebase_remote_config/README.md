# firebase_remote_config plugin

A Flutter plugin to use the [Firebase Remote Config API](https://firebase.google.com/products/remote-config/).

[![pub package](https://img.shields.io/pub/v/firebase_remote_config.svg)](https://pub.dartlang.org/packages/firebase_remote_config)

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

### Import the firebase_remote_config plugin
To use the firebase_remote_config plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/firebase_remote_config#pub-pkg-tab-installing).

### Android integration

Enable the Google services by configuring the Gradle scripts as such.

1. Add the classpath to the `[project]/android/build.gradle` file.
```gradle
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.2.1'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.2.0'
}
```

2. Add the apply plugin to the `[project]/android/app/build.gradle` file.
```gradle
// ADD THIS AT THE BOTTOM
apply plugin: 'com.google.gms.google-services'
```

*Note:* If this section is not completed you will get an error like this:
```
java.lang.IllegalStateException:
Default FirebaseApp is not initialized in this process [package name].
Make sure to call FirebaseApp.initializeApp(Context) first.
```

*Note:* When you are debugging on android, use a device or AVD with Google Play services.
Otherwise you will not be able to use Firebase Remote Config.

### Use the plugin

Add the following imports to your Dart code:
```dart
import 'package:firebase_remote_config/firebase_remote_config.dart';
```

Initialize `RemoteConfig`:
```dart
final RemoteConfig remoteConfig = await RemoteConfig.instance;
```

You can now use the Firebase `remoteConfig` to fetch remote configurations in your Dart code, e.g.
```dart
final defaults = <String, dynamic>{'welcome': 'default welcome'};
await remoteConfig.setDefaults(defaults);

await remoteConfig.fetch(expiration: const Duration(hours: 5));
await remoteConfig.activateFetched();
print('welcome message: ' + remoteConfig.getString('welcome'));
```

## Example

See the [example application](https://github.com/flutter/plugins/tree/master/packages/firebase_remote_config/example) source
for a complete sample app using the Firebase Remote Config.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug. Thank you!
