# local_auth

This Flutter plugin provides means to perform local, on-device authentication of
the user.

This means referring to biometric authentication on iOS (Touch ID or lock code)
and the fingerprint APIs on Android (introduced in Android 6.0).

## Usage in Dart

Import the relevant file:

```dart
import 'package:local_auth/local_auth.dart';
```

To check whether there is local authentication available on this device or not, call canCheckBiometrics:

```dart
bool canCheckBiometrics =
    await localAuth.canCheckBiometrics;
```

Currently the following biometric types are implemented:

- BiometricType.face
- BiometricType.fingerprint

To get a list of enrolled biometrics, call getAvailableBiometrics:

```dart
List<BiometricType> availableBiometrics =
    await auth.getAvailableBiometrics();

if (Platform.isIOS) {
    if (availableBiometrics.contains(BiometricType.face)) {
        // Face ID.
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        // Touch ID.
    }
}
```

We have default dialogs with an 'OK' button to show authentication error
messages for the following 2 cases:

1. Passcode/PIN/Pattern Not Set. The user has not yet configured a passcode on
   iOS or PIN/pattern on Android.
2. Touch ID/Fingerprint Not Enrolled. The user has not enrolled any
   fingerprints on the device.

Which means, if there's no fingerprint on the user's device, a dialog with
instructions will pop up to let the user set up fingerprint. If the user clicks
'OK' button, it will return 'false'.

Use the exported APIs to trigger local authentication with default dialogs:

The `authenticate()` method uses biometric authentication, but also allows
users to use pin, pattern, or passcode.

```dart
var localAuth = LocalAuthentication();
bool didAuthenticate =
    await localAuth.authenticate(
        localizedReason: 'Please authenticate to show account balance');
```

To authenticate using biometric authentication only, set `biometricOnly` to `true`.

```dart
var localAuth = LocalAuthentication();
bool didAuthenticate =
    await localAuth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        biometricOnly: true);
```

If you don't want to use the default dialogs, call this API with
'useErrorDialogs = false'. In this case, it will throw the error message back
and you need to handle them in your dart code:

```dart
bool didAuthenticate =
    await localAuth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        useErrorDialogs: false);
```

You can use our default dialog messages, or you can use your own messages by
passing in IOSAuthMessages and AndroidAuthMessages:

```dart
import 'package:local_auth/auth_strings.dart';

const iosStrings = const IOSAuthMessages(
    cancelButton: 'cancel',
    goToSettingsButton: 'settings',
    goToSettingsDescription: 'Please set up your Touch ID.',
    lockOut: 'Please reenable your Touch ID');
await localAuth.authenticate(
    localizedReason: 'Please authenticate to show account balance',
    useErrorDialogs: false,
    iOSAuthStrings: iosStrings);

```

If needed, you can manually stop authentication for android:

```dart

void _cancelAuthentication() {
    localAuth.stopAuthentication();
}

```

### Exceptions

There are 6 types of exceptions: PasscodeNotSet, NotEnrolled, NotAvailable, OtherOperatingSystem, LockedOut and PermanentlyLockedOut.
They are wrapped in LocalAuthenticationError class. You can
catch the exception and handle them by different types. For example:

```dart
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

try {
  bool didAuthenticate = await local_auth.authenticate(
      localizedReason: 'Please authenticate to show account balance');
} on PlatformException catch (e) {
  if (e.code == auth_error.notAvailable) {
    // Handle this exception here.
  }
}
```

## iOS Integration

Note that this plugin works with both Touch ID and Face ID. However, to use the latter,
you need to also add:

```xml
<key>NSFaceIDUsageDescription</key>
<string>Why is my app authenticating using face id?</string>
```

to your Info.plist file. Failure to do so results in a dialog that tells the user your
app has not been updated to use Face ID.

## Android Integration

Note that local_auth plugin requires the use of a FragmentActivity as
opposed to Activity. This can be easily done by switching to use
`FlutterFragmentActivity` as opposed to `FlutterActivity` in your
manifest (or your own Activity class if you are extending the base class).

Update your MainActivity.java:

```java
import android.os.Bundle;
import io.flutter.app.FlutterFragmentActivity;
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin;
import io.flutter.plugins.localauth.LocalAuthPlugin;

public class MainActivity extends FlutterFragmentActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FlutterAndroidLifecyclePlugin.registerWith(
                registrarFor(
                        "io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin"));
        LocalAuthPlugin.registerWith(registrarFor("io.flutter.plugins.localauth.LocalAuthPlugin"));
    }
}
```

OR

Update your MainActivity.kt:

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
```

Update your project's `AndroidManifest.xml` file to include the
`USE_FINGERPRINT` permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
<manifest>
```

On Android, you can check only for existence of fingerprint hardware prior
to API 29 (Android Q). Therefore, if you would like to support other biometrics
types (such as face scanning) and you want to support SDKs lower than Q,
_do not_ call `getAvailableBiometrics`. Simply call `authenticate` with `biometricOnly: true`.
This will return an error if there was no hardware available.

## Sticky Auth

You can set the `stickyAuth` option on the plugin to true so that plugin does not
return failure if the app is put to background by the system. This might happen
if the user receives a phone call before they get a chance to authenticate. With
`stickyAuth` set to false, this would result in plugin returning failure result
to the Dart app. If set to true, the plugin will retry authenticating when the
app resumes.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.dev/).

For help on editing plugin code, view the [documentation](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin).
