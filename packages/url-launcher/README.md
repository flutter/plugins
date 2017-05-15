# url_launcher

[![pub package](https://img.shields.io/pub/v/url_launcher.svg)](https://pub.dartlang.org/packages/url_launcher)

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
        onPressed: _launchURL,
        child: new Text('Show Flutter homepage'),
      ),
    ),
  ));
}

_launchURL() async {
  const url = 'https://flutter.io';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

```

## Supported URL schemes

The `launch` method takes a string argument containing a URL. This URL
can be formatted using a number of different URL schemes. The supported
URL schemes depend on the underlying platform and installed apps.

Common schemes supported by both iOS and Android:

| Scheme | Example | Action |
|---|---|---|
| `http:<URL>` , `https:<URL>` | `http://flutter.io` | Open URL in the default browser |
| `mailto:<email address>` | `mailto:smith@example.org` | Open <email address> in the default email app |
| `tel:<phone number>` | `tel:+1 555 010 999` | Make a phone call to <phone number> using the default phone app |
| `sms:<phone number>` | `sms:5550101234` | Send an SMS message to <phone number> using the default messaging app |

More details can be found here for [iOS](https://developer.apple.com/library/content/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html) and [Android](https://developer.android.com/guide/components/intents-common.html)

