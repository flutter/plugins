# firebase_admob

A plugin for [Flutter](https://flutter.io) that supports loading and
displaying banner, interstitial (full-screen), and rewarded video ads using the
[Firebase AdMob API](https://firebase.google.com/docs/admob/).

*Note*: This plugin is in beta, and may still have a few issues and missing APIs.
[Feedback](https://github.com/flutter/flutter/issues) and
[Pull Requests](https://github.com/flutter/plugins/pulls) are welcome.

## AndroidManifest changes

AdMob 17 requires the App ID to be included in the `AndroidManifest.xml`. Failure
to do so will result in a crash on launch of your app.  The line should look like:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="[ADMOB_APP_ID]"/>
```

where `[ADMOB_APP_ID]` is your App ID.  You must pass the same value when you 
initialize the plugin in your Dart code.

See https://goo.gl/fQ2neu for more information about configuring `AndroidManifest.xml`
and setting up your App ID.

## Initializing the plugin
The AdMob plugin must be initialized with an AdMob App ID.

```dart
FirebaseAdMob.instance.initialize(appId: appId);
```
*Note Android*:
Starting in version 17.0.0, if you are an AdMob publisher you are now required to add your AdMob app ID in your **AndroidManifest.xml** file. Once you find your AdMob app ID in the AdMob UI, add it to your manifest adding the following tag:

```xml
<manifest>
    <application>
        <!-- TODO: Replace with your real AdMob app ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-################~##########"/>
    </application>
</manifest>
```

Failure to add this tag will result in the app crashing at app launch with a message starting with *"The Google Mobile Ads SDK was initialized incorrectly."*

On Android, this value must be the same as the App ID value set in your 
`AndroidManifest.xml`.

## Using banners and interstitials
Banner and interstitial ads can be configured with target information.
And in the example below, the ads are given test ad unit IDs for a quick start.

```dart
MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  birthday: DateTime.now(),
  childDirected: false,
  designedForFamilies: false,
  gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd myBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);
```

Ads must be loaded before they're shown.
```dart
myBanner
  // typically this happens well before the ad is shown
  ..load()
  ..show(
    // Positions the banner ad 60 pixels from the bottom of the screen
    anchorOffset: 60.0,
    // Banner Position
    anchorType: AnchorType.bottom,
  );
```

```dart
myInterstitial
  ..load()
  ..show(
    anchorType: AnchorType.bottom,
    anchorOffset: 0.0,
  );
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
```dart
RewardedVideoAd.instance.load(myAdMobAdUnitId, targetingInfo);
```

To listen for events in the rewarded video ad lifecycle, apps can define a
function matching the `RewardedVideoAdListener` typedef, and assign it to the
`listener` instance variable in `RewardedVideoAd`. If set, the `listener`
function will be invoked whenever one of the events in the `RewardedVideAdEvent`
enum occurs. After a rewarded video ad loads, for example, the
`RewardedVideoAdEvent.loaded` is sent. Any time after that, apps can show the ad
by calling `show`:
```dart
RewardedVideoAd.instance.show();
```

When the AdMob SDK decides it's time to grant an in-app reward, it does so via
the `RewardedVideoAdEvent.rewarded` event:
```dart
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
