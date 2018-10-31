## 0.6.1+1

* Bump Android dependencies to latest.

## 0.6.1

* listener on MobileAd shouldn't be final.
* Ad listeners can to be set in or out of Ad initialization.

## 0.6.0

* Add nonPersonalizedAds option to MobileAdTargetingInfo

## 0.5.7

* Bumped mockito dependency to pick up Dart 2 support.

## 0.5.6

* Bump Android and Firebase dependency versions.

## 0.5.5

* Updated Gradle tooling to match Android Studio 3.1.2.

## 0.5.4+1

* Graduate to beta.

## 0.5.4

* Fixed a bug that was causing rewarded video failure event to be called on the wrong listener.

## 0.5.3

* Updated Google Play Services dependencies to version 15.0.0.
* Added handling of rewarded video completion event.

## 0.5.2

* Simplified podspec for Cocoapods 1.5.0, avoiding link issues in app archives.

## 0.5.1

* Fixed Dart 2 type errors.

## 0.5.0

* **Breaking change**. The BannerAd constructor now requires an AdSize
  parameter. BannerAds can be created with AdSize.smartBanner, or one of
  the other predefined AdSize values. Previously BannerAds were always
  defined with the smartBanner size.

## 0.4.0

* **Breaking change**. Set SDK constraints to match the Flutter beta release.

## 0.3.2

* Fixed Dart 2 type errors.

## 0.3.1

* Enabled use in Swift projects.

## 0.3.0

* Added support for rewarded video ads.
* **Breaking change**. The properties and parameters named "unitId" in BannerAd
  and InterstitialAd have been renamed to "adUnitId" to better match AdMob's
  documentation and UI.

## 0.2.3

* Simplified and upgraded Android project template to Android SDK 27.
* Updated package description.

## 0.2.2

* Added platform-specific App IDs and ad unit IDs to example.
* Separated load and show functionality for interstitials in example.

## 0.2.1

* Use safe area layout to place ad in iOS 11

## 0.2.0

* **Breaking change**. MobileAd TargetingInfo requestAgent is now hardcoded to 'flutter-alpha'.

## 0.1.0

* **Breaking change**. Upgraded to Gradle 4.1 and Android Studio Gradle plugin
  3.0.1. Older Flutter projects need to upgrade their Gradle setup as well in
  order to use this version of the plugin. Instructions can be found
  [here](https://github.com/flutter/flutter/wiki/Updating-Flutter-projects-to-Gradle-4.1-and-Android-Studio-Gradle-plugin-3.0.1).
* Relaxed GMS dependency to [11.4.0,12.0[

## 0.0.3

* Add FLT prefix to iOS types
* Change GMS dependency to 11.4.+

## 0.0.2

* Change GMS dependency to 11.+

## 0.0.1

* Initial Release: not ready for production use
