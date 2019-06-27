# firebase_crashlytics plugin

A Flutter plugin to use the [Firebase Crashlytics Service](https://firebase.google.com/docs/crashlytics/).

[![pub package](https://img.shields.io/pub/v/firebase_crashlytics.svg)](https://pub.dartlang.org/packages/firebase_crashlytics)

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

### Import the firebase_crashlytics plugin
To use the firebase_crashlytics plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/firebase_crashlytics#pub-pkg-tab-installing).

### Android integration

Enable the Google services by configuring the Gradle scripts as such.

1. Add Fabric repository to the `[project]/android/build.gradle` file.
```
repositories {
  google()
  jcenter()
  // Additional repository for fabric resources
  maven {
    url 'https://maven.fabric.io/public'
  }
}
```

2. Add the classpaths to the `[project]/android/build.gradle` file.
```gradle
dependencies {
  // Example existing classpath
  classpath 'com.android.tools.build:gradle:3.2.1'
  // Add the google services classpath
  classpath 'com.google.gms:google-services:4.2.0'
  // Add fabric classpath
  classpath 'io.fabric.tools:gradle:1.26.1'
}
```

2. Add the apply plugins to the `[project]/android/app/build.gradle` file.
```gradle
// ADD THIS AT THE BOTTOM
apply plugin: 'io.fabric'
apply plugin: 'com.google.gms.google-services'
```

*Note:* If this section is not completed you will get an error like this:
```
java.lang.IllegalStateException:
Default FirebaseApp is not initialized in this process [package name].
Make sure to call FirebaseApp.initializeApp(Context) first.
```

*Note:* When you are debugging on Android, use a device or AVD with Google Play services.
Otherwise you will not be able to use Firebase Crashlytics.

### iOS Integration

Add the Crashlytics run scripts

1. From Xcode select Runner from the project navigation.
1. Select the Build Phases tab.
1. Click + Add a new build phase, and select New Run Script Phase.
1. Add `${PODS_ROOT}/Fabric/run` to the `Type a script...` text box.
1. If on Xcode 10 Add your app's built Info.plist location to the Build Phase's Input Files field.
Eg: `$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)`

### Use the plugin

Add the following imports to your Dart code:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
```

Setup `Crashlytics`:
```dart
void main() {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = (FlutterErrorDetails details) {
    Crashlytics.instance.onError(details);
  };
  runApp(MyApp());
}
```

## Example

See the [example application](https://github.com/flutter/plugins/tree/master/packages/firebase_crashlytics/example) source
for a complete sample app using the Firebase Crashlytics.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug. Thank you!
