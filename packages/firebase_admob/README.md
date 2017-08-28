# firebase_admob

A plugin for [Flutter](https://flutter.io) that supports loading and
displaying banner and interstitial (full-screen) ads using the
[Firebase AdMob API](https://firebase.google.com/docs/admob/).

*Warning*: This plugin is still under development, some AdMob features are not
available yet and testing has been limited.
[Feedback](https://github.com/flutter/flutter/issues) and
[Pull Requests](https://github.com/flutter/plugins/pulls) are welcome.

## Using

Before showing an ad the plugin must be initialized with an AdMob app id:
```
FirebaseAdMob.instance.initialize(appId: appId);
```

Ads must be created with an AdMob unit id and they can include targeting information:
```
MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  birthday: new DateTime.now(),
  childDirected: true,
  gender: "male", // or "female", "unknown"
);

BannerAd myBanner = new BannerAd(
  unitId: myBannerAdUnitId,
  targetingInfo: targetingInfo,
);

InterstitialAd myInterstitial = new InterstitialAd(
  unitId: myInterstitalAdUnitId,
  targetingInfo: targetingInfo,
);
```

Ads must be loaded before they're shown.
```
myBanner
  ..load() // typically this happens well before the ad is shown
  ..show();
// InterstitialAds are loaded and shown in the same way
```

Ads can be disposed to free up plugin resources. Disposing a banner
ad that's been shown removes it from the screen. Interstitial ads
can't be programatically removed from view.

Ads can be created with a `MobileAdEvent` listener. The listener
can be used to detect when the ad has actually finished loading
(or failed to load at all).

## Limitations

This is just an initial version of the plugin. There are still some limitiations:

- Banner ads always appear at the bottom of the screen, they can't be positioned or animated into view.
- It's not possible to specify a banner ad's size.
- There's no support for rewarded video ads or native ads
- The existing tests are fairly rudimentary.
- There is no API doc
- The example should demonstrate how to show gate a route push with an interstitial ad

For Flutter plugins for other Firebase products, see [FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).
