# Google Dynamic Links for Firebase

[![pub package](https://img.shields.io/pub/v/firebase_dynamic_links.svg)](https://pub.dartlang.org/packages/firebase_dynamic_links)

A Flutter plugin to use the [Google Dynamic Links for Firebase API](https://firebase.google.com/docs/dynamic-links/).

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).

*Note*: This plugin is still under development, and some APIs might not be available yet. [Feedback](https://github.com/flutter/flutter/issues) and [Pull Requests](https://github.com/flutter/plugins/pulls) are most welcome!

## Usage

To use this plugin, add `firebase_dynamic_links` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/). You must also configure firebase dynamic links for each platform project: Android and iOS (see the example folder or https://codelabs.developers.google.com/codelabs/flutter-firebase/#4 for step by step details).

## Create Dynamic Links

You can create short or long Dynamic Links with the Firebase Dynamic Links Builder API. This API accepts either a long Dynamic Link or an object containing Dynamic Link parameters, and returns a URL like the following example:

```
https://abc123.app.goo.gl/WXYZ
```

You can create a Dynamic Link programmatically by setting the following parameters and getting the DynamicLinkParameters.url parameter.

```dart
final DynamicLinkParameters components = new DynamicLinkParameters(
  domain: 'abc123.app.goo.gl',
  link: Uri.parse('https://example.com/'),
  androidParameters: new AndroidParameters(
      packageName: 'com.example.android',
      minimumVersion: 125,
  ),
  iosParameters: new IosParameters(
      bundleId: 'com.example.ios',
      minimumVersion: '1.0.1',
      appStoreId: '123456789',
  ),
  googleAnalyticsParameters: new GoogleAnalyticsParameters(
      campaign: 'example-promo',
      medium: 'social',
      source: 'orkut',
  ),
  itunesConnectAnalyticsParameters: new ItunesConnectAnalyticsParameters(
    providerToken: '123456',
    campaignToken: 'example-promo',
  ),
  socialMetaTagParameters:  new SocialMetaTagParameters(
    title: 'Example of a Dynamic Link',
    description: 'This link works whether app is installed or not!',
  ),
);

final Uri dynamicLink = await components.buildUrl();
```

To create a short Dynamic Link, build DynamicLinkParameters the same way, but use the DynamicLinkParameters.shortUrl parameter.

```dart
final ShortDynamicLink shortDynamicLink = await components.buildShortLink();
final Uri shortUrl = shortDynamicLink.shortUrl;
```

To shorten a long Dynamic Link, use the DynamicLinkParameters.shortenUrl method.

```dart
final ShortDynamicLink shortenedLink = await DynamicLinkParameters.shortenUrl(
  Uri.parse('https://abc123.app.goo.gl/?link=https://example.com/&apn=com.example.android&ibn=com.example.ios'),
  new DynamicLinkParametersOptions(ShortDynamicLinkPathLength.short),
);

final Uri shortUrl = shortenedLink.shortUrl;
```

## Getting Started

See the `example` directory for a complete sample app using Google Dynamic Links for Firebase.