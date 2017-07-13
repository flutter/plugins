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

We have default dialogs with an 'OK' button to show authentication error
messages for the following 2 cases:

1.  Passcode/PIN/Pattern Not Set. The user has not yet configured a passcode on
    iOS or PIN/pattern on Android.
2.  Touch ID/Fingerprint Not Enrolled. The user has not enrolled any
    fingerprints on the device.

Which means, if there's no fingerprint on the user's device, a dialog with
instructions will pop up to let the user set up fingerprint. If the user clicks
'OK' button, it will return 'false'.

Use the exported APIs to trigger local authentication with default dialogs:

```dart
var localAuth = new LocalAuthentication();
bool didAuthenticate =
    await localAuth.authenticateWithBiometrics(
    localizedReason: 'Please authenticate to show account balance');
```

If you don't want to use the default dialogs, call this API with
'useErrorDialogs = false'. In this case, it will throw the error message back
and you need to handle them in your dart code:

```dart
bool didAuthenticate =
    await localAuth.authenticateWithBiometrics(
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
await localAuth.authenticateWithBiometrics(
    localizedReason: 'Please authenticate to show account balance',
    useErrorDialogs: false,
    iOSAuthStrings: iosStrings);

```

### Exceptions

There are 4 types of exceptions: PasscodeNotSet, NotEnrolled, NotAvailable and
OtherOperatingSystem. They are wrapped in LocalAuthenticationError class. You can
catch the exception and handle them by different types. For example:

```dart
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

try {
  bool didAuthenticate = await local_auth.authenticateWithBiometrics(
      localizedReason: 'Please authenticate to show account balance');
} on PlatformException catch (e) {
  if (e.code == auth_error.notAvailable) {
    // Handle this exception here.
  }
}
```

## Android integration

Update your project's `AndroidManifest.xml` file to include the
`USE_FINGERPRINT` permissions:

```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
<manifest>
```

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).
