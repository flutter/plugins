# local_auth

<?code-excerpt path-base="excerpts/packages/local_auth_example"?>

This Flutter plugin provides means to perform local, on-device authentication of
the user.

On supported devices, this includes authentication with biometrics such as
fingerprint or facial recognition.

|             | Android   | iOS  | Windows     |
|-------------|-----------|------|-------------|
| **Support** | SDK 16+\* | 9.0+ | Windows 10+ |

## Usage

### Device Capabilities

To check whether there is local authentication available on this device or not,
call `canCheckBiometrics` (if you need biometrics support) and/or
`isDeviceSupported()` (if you just need some device-level authentication):

<?code-excerpt "readme_excerpts.dart (CanCheck)"?>
```dart
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
```

Currently the following biometric types are implemented:

- BiometricType.face
- BiometricType.fingerprint
- BiometricType.weak
- BiometricType.strong

### Enrolled Biometrics

`canCheckBiometrics` only indicates whether hardware support is available, not
whether the device has any biometrics enrolled. To get a list of enrolled
biometrics, call `getAvailableBiometrics()`.

The types are device-specific and platform-specific, and other types may be
added in the future, so when possible you should not rely on specific biometric
types and only check that some biometric is enrolled:

<?code-excerpt "readme_excerpts.dart (Enrolled)"?>
```dart
final List<BiometricType> availableBiometrics =
    await auth.getAvailableBiometrics();

if (availableBiometrics.isNotEmpty) {
  // Some biometrics are enrolled.
}

if (availableBiometrics.contains(BiometricType.strong) ||
    availableBiometrics.contains(BiometricType.face)) {
  // Specific types of biometrics are available.
  // Use checks like this with caution!
}
```

### Options

The `authenticate()` method uses biometric authentication when possible, but
also allows fallback to pin, pattern, or passcode.

<?code-excerpt "readme_excerpts.dart (AuthAny)"?>
```dart
try {
  final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Please authenticate to show account balance');
  // ···
} on PlatformException {
  // ...
}
```

To require biometric authentication, pass `AuthenticationOptions` with
`biometricOnly` set to `true`.

<?code-excerpt "readme_excerpts.dart (AuthBioOnly)"?>
```dart
final bool didAuthenticate = await auth.authenticate(
    localizedReason: 'Please authenticate to show account balance',
    options: const AuthenticationOptions(biometricOnly: true));
```

*Note*: `biometricOnly` is not supported on Windows since the Windows implementation's underlying API (Windows Hello) doesn't support selecting the authentication method.

#### Dialogs

The plugin provides default dialogs for the following cases:

1. Passcode/PIN/Pattern Not Set: The user has not yet configured a passcode on
   iOS or PIN/pattern on Android.
2. Biometrics Not Enrolled: The user has not enrolled any biometrics on the
   device.

If a user does not have the necessary authentication enrolled when
`authenticate` is called, they will be given the option to enroll at that point,
or cancel authentication.

If you don't want to use the default dialogs, set the `useErrorDialogs` option
to `false` to have `authenticate` immediately return an error in those cases.

<?code-excerpt "readme_excerpts.dart (NoErrorDialogs)"?>
```dart
import 'package:local_auth/error_codes.dart' as auth_error;
// ···
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // ···
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.notEnrolled) {
        // ...
      } else {
        // ...
      }
    }
```

If you want to customize the messages in the dialogs, you can pass
`AuthMessages` for each platform you support. These are platform-specific, so
you will need to import the platform-specific implementation packages. For
instance, to customize Android and iOS:

<?code-excerpt "readme_excerpts.dart (CustomMessages)"?>
```dart
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
// ···
    final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ]);
```

See the platform-specific classes for details about what can be customized on
each platform.

### Exceptions

`authenticate` throws `PlatformException`s in many error cases. See
`error_codes.dart` for known error codes that you may want to have specific
handling for. For example:

<?code-excerpt "readme_excerpts.dart (ErrorHandling)"?>
```dart
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
// ···
  final LocalAuthentication auth = LocalAuthentication();
  // ···
    try {
      final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to show account balance',
          options: const AuthenticationOptions(useErrorDialogs: false));
      // ···
    } on PlatformException catch (e) {
      if (e.code == auth_error.notEnrolled) {
        // Add handling of no hardware here.
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        // ...
      } else {
        // ...
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

\* The plugin will build and run on SDK 16+, but `isDeviceSupported()` will
always return false before SDK 23 (Android 6.0).

### Activity Changes

Note that `local_auth` requires the use of a `FragmentActivity` instead of an
`Activity`. To update your application:

* If you are using `FlutterActivity` directly, change it to
`FlutterFragmentActivity` in your `AndroidManifest.xml`.
* If you are using a custom activity, update your `MainActivity.java`:

    ```java
    import io.flutter.embedding.android.FlutterFragmentActivity;

    public class MainActivity extends FlutterFragmentActivity {
        // ...
    }
    ```

    or MainActivity.kt:

    ```kotlin
    import io.flutter.embedding.android.FlutterFragmentActivity

    class MainActivity: FlutterFragmentActivity() {
        // ...
    }
    ```

    to inherit from `FlutterFragmentActivity`.

### Permissions

Update your project's `AndroidManifest.xml` file to include the
`USE_BIOMETRIC` permissions:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          package="com.example.app">
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<manifest>
```

### Compatibility

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
