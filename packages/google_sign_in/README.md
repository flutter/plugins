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

# iOS integration

To access Google Sign-In, you'll need to make sure to [register your
application](https://developers.google.com/mobile/add?platform=ios). Add
the generated GoogleService-Info.plist to root of your Runner project in Xcode,
so that the Google Sign-In framework can determine your client id.

You'll need to add this to the main dictionary of your application's Info.plist:

```
        <key>CFBundleURLTypes</key>
        <array>
                <dict>
                        <key>CFBundleTypeRole</key>
                        <string>Editor</string>
                        <key>CFBundleURLSchemes</key>
                        <array>
                                <!-- bundle id, for example: -->
                                <string>com.yourcompany.myapp</string>
                        </array>
                </dict>
                <dict>
                        <key>CFBundleTypeRole</key>
                        <string>Editor</string>
                        <key>CFBundleURLSchemes</key>
                        <array>
                                <!-- reverse url of your client id, for example: -->
        <string>com.googleusercontent.apps.861823949799-11qfr04mrfh2mndp3el2vgc0e357a2t6</string>
                        </array>
                </dict>
        </array>
```

## Usage

Add the following import to your Dart code:

```
import 'package:google_sign_in/google_sign_in.dart';
```

Initialize GoogleSignIn with the scopes you want:

```
GoogleSignIn.initialize(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
);
```

You can now use the `GoogleSignIn` class to authenticate in your Dart code, e.g.

```
GoogleSignInAccount account = await (await GoogleSignIn.instance).signIn();
```

See google_sign_in.dart for more API details.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug. Thank you!
