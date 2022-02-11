# url_launcher

[![pub package](https://img.shields.io/pub/v/url_launcher.svg)](https://pub.dev/packages/url_launcher)

A Flutter plugin for launching a URL. Supports
iOS, Android, web, Windows, macOS, and Linux.

## Usage

To use this plugin, add `url_launcher` as a [dependency in your pubspec.yaml file](https://flutter.dev/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const String _url = 'https://flutter.dev';

void main() => runApp(
      const MaterialApp(
        home: Material(
          child: Center(
            child: RaisedButton(
              onPressed: _launchURL,
              child: Text('Show Flutter homepage'),
            ),
          ),
        ),
      ),
    );

void _launchURL() async {
  if (!await launch(_url)) throw 'Could not launch $_url';
}
```

See the example app for more complex examples.

## Configuration

### iOS
Add any URL schemes passed to `canLaunch` as `LSApplicationQueriesSchemes` entries in your Info.plist file.

Example:
```
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>https</string>
  <string>http</string>
</array>
```

See [`-[UIApplication canOpenURL:]`](https://developer.apple.com/documentation/uikit/uiapplication/1622952-canopenurl) for more details.

### Android

Starting from API 30 Android requires package visibility configuration in your
`AndroidManifest.xml` otherwise `canLaunch` will return `false`. A `<queries>`
element must be added to your manifest as a child of the root element.

The snippet below shows an example for an application that uses `https`, `tel`,
and `mailto` URLs with `url_launcher`. See
[the Android documentation](https://developer.android.com/training/package-visibility/use-cases)
for examples of other queries.

``` xml
<queries>
  <!-- If your app opens https URLs -->
  <intent>
    <action android:name="android.intent.action.VIEW" />
    <data android:scheme="https" />
  </intent>
  <!-- If your app makes calls -->
  <intent>
    <action android:name="android.intent.action.DIAL" />
    <data android:scheme="tel" />
  </intent>
  <!-- If your sends SMS messages -->
  <intent>
    <action android:name="android.intent.action.SENDTO" />
    <data android:scheme="smsto" />
  </intent>
  <!-- If your app sends emails -->
  <intent>
    <action android:name="android.intent.action.SEND" />
    <data android:mimeType="*/*" />
  </intent>
</queries>
```

## Supported URL schemes

The [`launch`](https://pub.dev/documentation/url_launcher/latest/url_launcher/launch.html) method
takes a string argument containing a URL. This URL
can be formatted using a number of different URL schemes. The supported
URL schemes depend on the underlying platform and installed apps.

Commonly used schemes include:

| Scheme | Example | Action |
|:---|:---|:---|
| `https:<URL>` | `https://flutter.dev` | Open URL in the default browser |
| `mailto:<email address>?subject=<subject>&body=<body>` | `mailto:smith@example.org?subject=News&body=New%20plugin` | Create email to <email address> in the default email app |
| `tel:<phone number>` | `tel:+1-555-010-999` | Make a phone call to <phone number> using the default phone app |
| `sms:<phone number>` | `sms:5550101234` | Send an SMS message to <phone number> using the default messaging app |
| `file:<path>` | `file:/home` | Open file or folder using default app association, supported on desktop platforms |

More details can be found here for [iOS](https://developer.apple.com/library/content/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html)
and [Android](https://developer.android.com/guide/components/intents-common.html)

**Note**: URL schemes are only supported if there are apps installed on the device that can
support them. For example, iOS simulators don't have a default email or phone
apps installed, so can't open `tel:` or `mailto:` links.

### Encoding URLs

URLs must be properly encoded, especially when including spaces or other special
characters. This can be done using the
[`Uri` class](https://api.dart.dev/dart-core/Uri-class.html).
For example:
```dart
String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

final Uri emailLaunchUri = Uri(
  scheme: 'mailto',
  path: 'smith@example.com',
  query: encodeQueryParameters(<String, String>{
    'subject': 'Example Subject & Symbols are allowed!'
  }),
);

launch(emailLaunchUri.toString());
```

**Warning**: For any scheme other than `http` or `https`, you should use the
`query` parameter and the `encodeQueryParameters` function shown above rather
than `Uri`'s `queryParameters` constructor argument, due to
[a bug](https://github.com/dart-lang/sdk/issues/43838) in the way `Uri`
encodes query parameters. Using `queryParameters` will result in spaces being
converted to `+` in many cases.

### Handling missing URL receivers

A particular mobile device may not be able to receive all supported URL schemes.
For example, a tablet may not have a cellular radio and thus no support for
launching a URL using the `sms` scheme, or a device may not have an email app
and thus no support for launching a URL using the `mailto` scheme.

We recommend checking which URL schemes are supported using the
[`canLaunch`](https://pub.dev/documentation/url_launcher/latest/url_launcher/canLaunch.html)
in most cases. If the `canLaunch` method returns false, as a
best practice we suggest adjusting the application UI so that the unsupported
URL is never triggered; for example, if the `mailto` scheme is not supported, a
UI button that would have sent feedback email could be changed to instead open
a web-based feedback form using an `https` URL.

## Browser vs In-app Handling
By default, Android opens up a browser when handling URLs. You can pass
`forceWebView: true` parameter to tell the plugin to open a WebView instead.
If you do this for a URL of a page containing JavaScript, make sure to pass in
`enableJavaScript: true`, or else the launch method will not work properly. On
iOS, the default behavior is to open all web URLs within the app. Everything
else is redirected to the app handler.

## File scheme handling
`file:` scheme can be used on desktop platforms: `macOS`, `Linux` and `Windows`.

We recommend checking first whether the directory or file exists before calling `launch`.

Example:
```dart
var filePath = '/path/to/file';
final Uri uri = Uri.file(filePath);

if (await File(uri.toFilePath()).exists()) {
  if (!await launch(uri.toString())) {
    throw 'Could not launch $uri';
  }
}
```

### macOS file access configuration

If you need to access files outside of your application's sandbox, you will need to have the necessary 
[entitlements](https://docs.flutter.dev/desktop#entitlements-and-the-app-sandbox).
