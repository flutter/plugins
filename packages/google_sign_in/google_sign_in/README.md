# google_sign_in

[![pub package](https://img.shields.io/pub/v/google_sign_in.svg)](https://pub.dartlang.org/packages/google_sign_in)

A Flutter plugin for [Google Sign In](https://developers.google.com/identity/).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Android integration

To access Google Sign-In, you'll need to make sure to [register your
application](https://developers.google.com/mobile/add?platform=android).

You don't need to include the google-services.json file in your app unless you
are using Google services that require it. You do need to enable the OAuth APIs
that you want, using the [Google Cloud Platform API
manager](https://console.developers.google.com/). For example, if you
want to mimic the behavior of the Google Sign-In sample app, you'll need to
enable the [Google People API](https://developers.google.com/people/).

Make sure you've filled out all required fields in the console for [OAuth consent screen](https://console.developers.google.com/apis/credentials/consent). Otherwise, you may encounter `APIException` errors.

## iOS integration

1. [First register your application](https://developers.google.com/mobile/add?platform=ios).
2. Make sure the file you download in step 1 is named `GoogleService-Info.plist`.
3. Move or copy `GoogleService-Info.plist` into the `[my_project]/ios/Runner` directory.
4. Open Xcode, then right-click on `Runner` directory and select `Add Files to "Runner"`.
5. Select `GoogleService-Info.plist` from the file manager.
6. A dialog will show up and ask you to select the targets, select the `Runner` target.
7. Then add the `CFBundleURLTypes` attributes below into the `[my_project]/ios/Runner/Info.plist` file.

```xml
<!-- Put me in the [my_project]/ios/Runner/Info.plist file -->
<!-- Google Sign-in Section -->
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- TODO Replace this value: -->
			<!-- Copied from GoogleService-Info.plist key REVERSED_CLIENT_ID -->
			<string>com.googleusercontent.apps.861823949799-vc35cprkp249096uujjn0vvnmcvjppkn</string>
		</array>
	</dict>
</array>
<!-- End of the Google Sign-in Section -->
```

### iOS additional requirement

Note that according to https://developer.apple.com/sign-in-with-apple/get-started,
starting June 30, 2020, apps that use login services must also offer a "Sign in
with Apple" option when submitting to the Apple App Store.

Consider also using an Apple sign in plugin from pub.dev.

The Flutter Favorite [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)
plugin could be an option.

## Usage

### Import the package
To use this plugin, follow the [plugin installation instructions](https://pub.dartlang.org/packages/google_sign_in#pub-pkg-tab-installing).

### Use the plugin
Add the following import to your Dart code:

```dart
import 'package:google_sign_in/google_sign_in.dart';
```

Initialize GoogleSignIn with the scopes you want:

```dart
GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);
```
[Full list of available scopes](https://developers.google.com/identity/protocols/googlescopes).

You can now use the `GoogleSignIn` class to authenticate in your Dart code, e.g.

```dart
Future<void> _handleSignIn() async {
  try {
    await _googleSignIn.signIn();
  } catch (error) {
    print(error);
  }
}
```

## Example

Find the example wiring in the [Google sign-in example application](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/example/lib/main.dart).

## API details

See the [google_sign_in.dart](https://github.com/flutter/plugins/blob/master/packages/google_sign_in/google_sign_in/lib/google_sign_in.dart) for more API details.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug. Thank you!
