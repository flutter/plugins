# url_launcher

A Flutter plugin for launching a URL in the mobile platform. Supports iOS and Android.

## Usage

Get this plugin as described [here] (https://www.dartlang.org/tools/pub/get-started).

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
  UrlLauncher.launch('https://flutter.io');
}

```

## Supported URL schemes

The supported URL schemes depend on the underlying platform and installed system apps.

Common schemes supported by both iOS and Android:

* http:<URL> , https:<URL>
* mailto:<email-address>
* tel:<phone-number>
* sms:<phone-number>

More details can be found here for [iOS](https://developer.apple.com/library/content/featuredarticles/iPhoneURLScheme_Reference/Introduction/Introduction.html) or [Android](https://developer.android.com/guide/components/intents-common.html)


## More info

For more info on Flutter plugins see [this guide](https://flutter.io/platform-plugins/)
