# firebase_admob

A plugin for [Flutter](https://flutter.io) that supports loading and
displaying banner, interstitial (full-screen), and rewarded video ads using the
[Firebase AdMob API](https://firebase.google.com/docs/admob/).

*Warning*: This plugin is still under development, some AdMob features are not
available yet and testing has been limited.
[Feedback](https://github.com/flutter/flutter/issues) and
[Pull Requests](https://github.com/flutter/plugins/pulls) are welcome.

## Initializing the plugin

Before any other methods are invoked, the plugin must be initialized with an
AdMob App ID:
```
FirebaseAdMob.instance.initialize(appId: appId);
```

## Using banners and interstitials

Banner and interstitial ads must be created with an AdMob ad unit ID, and they
can include targeting information:
```
MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  birthday: new DateTime.now(),
  childDirected: true,
  gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
);

BannerAd myBanner = new BannerAd(
  adUnitId: myBannerAdUnitId,
  size: AdSize.banner,
  targetingInfo: targetingInfo,
);

InterstitialAd myInterstitial = new InterstitialAd(
  adUnitId: myInterstitalAdUnitId,
  targetingInfo: targetingInfo,
);
```

Ads must be loaded before they're shown.
```
myBanner
  ..load() // typically this happens well before the ad is shown
  ..show(anchorOffset: 60.0, anchorType: AnchorType.bottom);
// Positions the banner ad 60 pixels from the bottom of the screen
// InterstitialAds are loaded and shown in the same way
```

`BannerAd` and `InterstitialAd` objects can be disposed to free up plugin
resources. Disposing a banner ad that's been shown removes it from the screen.
Interstitial ads, however, can't be programmatically removed from view.

Banner and interstitial ads can be created with a `MobileAdEvent` listener. The
listener can be used to detect when the ad has actually finished loading
(or failed to load at all).

## Using rewarded video ads

Unlike banners and interstitials, rewarded video ads are loaded one at a time
via a singleton object, `RewardedVideoAd.instance`. Its `load` method takes an
AdMob ad unit ID and an instance of `MobileAdTargetingInfo`:
```
RewardedVideoAd.instance.load(myAdMobAdUnitId, targetingInfo);
```

To listen for events in the rewarded video ad lifecycle, apps can define a
function matching the `RewardedVideoAdListener` typedef, and assign it to the
`listener` instance variable in `RewardedVideoAd`. If set, the `listener`
function will be invoked whenever one of the events in the `RewardedVideAdEvent`
enum occurs. After a rewarded video ad loads, for example, the
`RewardedVideoAdEvent.loaded` is sent. Any time after that, apps can show the ad
by calling `show`:
```
RewardedVideoAd.instance.show();
```

When the AdMob SDK decides it's time to grant an in-app reward, it does so via
the `RewardedVideoAdEvent.rewarded` event:
```
RewardedVideoAd.instance.listener =
    (RewardedVideoAdEvent event, [String rewardType, int rewardAmount]) {
  if (event == RewardedVideoAdEvent.rewarded) {
    setState(() {
      // Here, apps should update state to reflect the reward.
      _goldCoins += rewardAmount;
    });
  }
};
```

Because `RewardedVideoAd` is a singleton object, it does not offer a `dispose`
method.

## Limitations

This is just an initial version of the plugin. There are still some
limitations:

- Banner ads have limited positioning functionality. They can be positioned at the top or the bottom of the screen and at a logical pixel offset from the edge.
- Banner ads cannot be animated into view.
- It's not possible to specify a banner ad's size.
- There's no support for native ads.
- The existing tests are fairly rudimentary.
- There is no API doc.
- The example should demonstrate how to show gate a route push with an
  interstitial ad

For Flutter plugins for other Firebase products, see
[FlutterFire.md](https://github.com/flutter/plugins/blob/master/FlutterFire.md).
