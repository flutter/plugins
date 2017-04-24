# url_launcher

A Flutter plugin for launching a URL in the mobile platform. Supports iOS and Android.

## Usage
To use this plugin, add url_launcher as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(new Scaffold(
    body: new Center(
      child: new RaisedButton(
        onPressed: launchURL,
        child: new Text('Show Flutter homepage'),
      ),
    ),
  ));
}

launchURL() {
  launch('https://flutter.io');
}

```

## Supported URL schemes

The `launch` method takes a string argument containing a URL. This URL
can be formatted using a number of different URL schemes. The supported
URL schemes depend on the underlying platform and installed apps.

Common schemes supported by both iOS and Android:

* http:<URL> , https:<URL>
* mailto:<email-address>
* tel:<phone-number>
* sms:<phone-number>

More details can be found here for [iOS](https://developer.apple.com/library/content/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html) and [Android](https://developer.android.com/guide/components/intents-common.html)

