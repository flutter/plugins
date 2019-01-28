// ignore_for_file: deprecated_member_use_from_same_package
// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// [MobileAd] status changes reported to [MobileAdListener]s.
///
/// Applications can wait until an ad is [MobileAdEvent.loaded] before showing
/// it, to ensure that the ad is displayed promptly.
enum MobileAdEvent {
  loaded,
  failedToLoad,
  clicked,
  impression,
  opened,
  leftApplication,
  closed,
}

/// The user's gender for the sake of ad targeting using [MobileAdTargetingInfo].
// Warning: the index values of the enums must match the values of the corresponding
// AdMob constants. For example MobileAdGender.female.index == kGADGenderFemale.
@Deprecated('This functionality is deprecated in AdMob without replacement.')
enum MobileAdGender {
  unknown,
  male,
  female,
}

/// Signature for a [MobileAd] status change callback.
typedef void MobileAdListener(MobileAdEvent event);

/// Targeting info per the native AdMob API.
///
/// This class's properties mirror the native AdRequest API. See for example:
/// [AdRequest.Builder for Android](https://firebase.google.com/docs/reference/android/com/google/android/gms/ads/AdRequest.Builder).
class MobileAdTargetingInfo {
  const MobileAdTargetingInfo(
      {this.keywords,
      this.contentUrl,
      @Deprecated('This functionality is deprecated in AdMob without replacement.')
          this.birthday,
      @Deprecated('This functionality is deprecated in AdMob without replacement.')
          this.gender,
      @Deprecated('Use `childDirected` instead.')
          this.designedForFamilies,
      this.childDirected,
      this.testDevices,
      this.nonPersonalizedAds});

  final List<String> keywords;
  final String contentUrl;
  @Deprecated('This functionality is deprecated in AdMob without replacement.')
  final DateTime birthday;
  @Deprecated('This functionality is deprecated in AdMob without replacement.')
  final MobileAdGender gender;
  @Deprecated(
      'This functionality is deprecated in AdMob.  Use `childDirected` instead.')
  final bool designedForFamilies;
  final bool childDirected;
  final List<String> testDevices;
  final bool nonPersonalizedAds;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'requestAgent': 'flutter-alpha',
    };

    if (keywords != null && keywords.isNotEmpty) {
      assert(keywords.every((String s) => s != null && s.isNotEmpty));
      json['keywords'] = keywords;
    }
    if (nonPersonalizedAds != null)
      json['nonPersonalizedAds'] = nonPersonalizedAds;
    if (contentUrl != null && contentUrl.isNotEmpty)
      json['contentUrl'] = contentUrl;
    if (birthday != null) json['birthday'] = birthday.millisecondsSinceEpoch;
    if (gender != null) json['gender'] = gender.index;
    if (designedForFamilies != null)
      json['designedForFamilies'] = designedForFamilies;
    if (childDirected != null) json['childDirected'] = childDirected;
    if (testDevices != null && testDevices.isNotEmpty) {
      assert(testDevices.every((String s) => s != null && s.isNotEmpty));
      json['testDevices'] = testDevices;
    }

    return json;
  }
}

enum AnchorType { bottom, top }

// The types of ad sizes supported for banners. The names of the values are used
// in MethodChannel calls to iOS and Android, and should not be changed.
enum AdSizeType {
  WidthAndHeight,
  SmartBanner,
}

/// [AdSize] represents the size of a banner ad. There are six sizes available,
/// which are the same for both iOS and Android. See the guides for banners on
/// [Android](https://developers.google.com/admob/android/banner#banner_sizes)
/// and [iOS](https://developers.google.com/admob/ios/banner#banner_sizes) for
/// additional details.
class AdSize {
  // Private constructor. Apps should use the static constants rather than
  // create their own instances of [AdSize].
  const AdSize._({
    @required this.width,
    @required this.height,
    @required this.adSizeType,
  });

  final int height;
  final int width;
  final AdSizeType adSizeType;

  /// The standard banner (320x50) size.
  static const AdSize banner = AdSize._(
    width: 320,
    height: 50,
    adSizeType: AdSizeType.WidthAndHeight,
  );

  /// The large banner (320x100) size.
  static const AdSize largeBanner = AdSize._(
    width: 320,
    height: 100,
    adSizeType: AdSizeType.WidthAndHeight,
  );

  /// The medium rectangle (300x250) size.
  static const AdSize mediumRectangle = AdSize._(
    width: 300,
    height: 250,
    adSizeType: AdSizeType.WidthAndHeight,
  );

  /// The full banner (468x60) size.
  static const AdSize fullBanner = AdSize._(
    width: 468,
    height: 60,
    adSizeType: AdSizeType.WidthAndHeight,
  );

  /// The leaderboard (728x90) size.
  static const AdSize leaderboard = AdSize._(
    width: 728,
    height: 90,
    adSizeType: AdSizeType.WidthAndHeight,
  );

  /// The smart banner size. Smart banners are unique in that the width and
  /// height values declared here aren't used. At runtime, the Mobile Ads SDK
  /// will automatically adjust the banner's width to match the width of the
  /// displaying device's screen. It will also set the banner's height using a
  /// calculation based on the displaying device's height. For more info see the
  /// [Android](https://developers.google.com/admob/android/banner) and
  /// [iOS](https://developers.google.com/admob/ios/banner) banner ad guides.
  static const AdSize smartBanner = AdSize._(
    width: 0,
    height: 0,
    adSizeType: AdSizeType.SmartBanner,
  );
}

/// A mobile [BannerAd] or [InterstitialAd] for the [FirebaseAdMobPlugin].
///
/// A [MobileAd] must be loaded with [load] before it is shown with [show].
///
/// A valid [adUnitId] is required.
abstract class MobileAd {
  /// Default constructor, used by subclasses.
  MobileAd(
      {@required this.adUnitId,
      MobileAdTargetingInfo targetingInfo,
      this.listener})
      : _targetingInfo = targetingInfo ?? const MobileAdTargetingInfo() {
    assert(adUnitId != null && adUnitId.isNotEmpty);
    assert(_allAds[id] == null);
    _allAds[id] = this;
  }

  static final Map<int, MobileAd> _allAds = <int, MobileAd>{};

  /// Optional targeting info per the native AdMob API.
  MobileAdTargetingInfo get targetingInfo => _targetingInfo;
  final MobileAdTargetingInfo _targetingInfo;

  /// Identifies the source of ads for your application.
  ///
  /// For testing use a [sample ad unit](https://developers.google.com/admob/ios/test-ads#sample_ad_units).
  final String adUnitId;

  /// Called when the status of the ad changes.
  MobileAdListener listener;

  /// An internal id that identifies this mobile ad to the native AdMob plugin.
  ///
  /// Plugin log messages will identify this property as the ad's `mobileAdId`.
  int get id => hashCode;

  /// Start loading this ad.
  Future<bool> load();

  /// Show this ad.
  ///
  /// The ad must have been loaded with [load] first. If loading hasn't finished
  /// the ad will not actually appear until the ad has finished loading.
  ///
  /// The [listener] will be notified when the ad has finished loading or fails
  /// to do so. An ad that fails to load will not be shown.
  ///
  /// anchorOffset is the logical pixel offset from the edge of the screen (default 0.0)
  /// anchorType place advert at top or bottom of screen (default bottom)
  Future<bool> show(
      {double anchorOffset = 0.0, AnchorType anchorType = AnchorType.bottom}) {
    return _invokeBooleanMethod("showAd", <String, dynamic>{
      'id': id,
      'anchorOffset': anchorOffset.toString(),
      'anchorType': anchorType == AnchorType.top ? "top" : "bottom"
    });
  }

  /// Free the plugin resources associated with this ad.
  ///
  /// Disposing a banner ad that's been shown removes it from the screen.
  /// Interstitial ads can't be programmatically removed from view.
  Future<bool> dispose() {
    assert(_allAds[id] != null);
    _allAds[id] = null;
    return _invokeBooleanMethod("disposeAd", <String, dynamic>{'id': id});
  }

  Future<bool> isLoaded() {
    return _invokeBooleanMethod("isAdLoaded", <String, dynamic>{
      'id': id,
    });
  }
}

/// A banner ad for the [FirebaseAdMobPlugin].
class BannerAd extends MobileAd {
  /// Create a BannerAd.
  ///
  /// A valid [adUnitId] is required.
  BannerAd({
    @required String adUnitId,
    @required this.size,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  }) : super(
            adUnitId: adUnitId,
            targetingInfo: targetingInfo,
            listener: listener);

  final AdSize size;

  /// These are AdMob's test ad unit IDs, which always return test ads. You're
  /// encouraged to use them for testing in your own apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  Future<bool> load() {
    return _invokeBooleanMethod("loadBannerAd", <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
      'targetingInfo': targetingInfo?.toJson(),
      'width': size.width,
      'height': size.height,
      'adSizeType': size.adSizeType.toString(),
    });
  }
}

/// A full-screen interstitial ad for the [FirebaseAdMobPlugin].
class InterstitialAd extends MobileAd {
  /// Create an Interstitial.
  ///
  /// A valid [adUnitId] is required.
  InterstitialAd({
    String adUnitId,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  }) : super(
            adUnitId: adUnitId,
            targetingInfo: targetingInfo,
            listener: listener);

  /// A platform-specific AdMob test ad unit ID for interstitials. This ad unit
  /// has been specially configured to always return test ads, and developers
  /// are encouraged to use it while building and testing their apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  @override
  Future<bool> load() {
    return _invokeBooleanMethod("loadInterstitialAd", <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
      'targetingInfo': targetingInfo?.toJson(),
    });
  }
}

/// [RewardedVideoAd] status changes reported to [RewardedVideoAdListener]s.
///
/// The [rewarded] event is particularly important, since it indicates that the
/// user has watched a video for long enough to be given an in-app reward.
enum RewardedVideoAdEvent {
  loaded,
  failedToLoad,
  opened,
  leftApplication,
  closed,
  rewarded,
  started,
  completed,
}

/// Signature for a [RewardedVideoAd] status change callback. The optional
/// parameters are only used when the [RewardedVideoAdEvent.rewarded] event
/// is sent, when they'll contain the reward amount and reward type that were
/// configured for the AdMob ad unit when it was created. They will be null for
/// all other events.
typedef void RewardedVideoAdListener(RewardedVideoAdEvent event,
    {String rewardType, int rewardAmount});

/// An AdMob rewarded video ad.
///
/// This class is a singleton, and [RewardedVideoAd.instance] provides a
/// reference to the single instance, which is created at launch. The native
/// Android and iOS APIs for AdMob use a singleton to manage rewarded video ad
/// objects, and that pattern is reflected here.
///
/// Apps should assign a callback function to [RewardedVideoAd]'s listener
/// property in order to receive reward notifications from the AdMob SDK:
/// ```
/// RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
///     [String rewardType, int rewardAmount]) {
///     print("You were rewarded with $rewardAmount $rewardType!");
///   }
/// };
/// ```
///
/// The function will be invoked when any of the events in
/// [RewardedVideoAdEvent] occur.
///
/// To load and show ads, call the load method:
/// ```
/// RewardedVideoAd.instance.load(myAdUnitString, myTargetingInfoObj);
/// ```
///
/// Later (any point after your listener callback receives the
/// RewardedVideoAdEvent.loaded event), call the show method:
/// ```
/// RewardedVideoAd.instance.show();
/// ```
///
/// Only one rewarded video ad can be loaded at a time. Because the video assets
/// are so large, it's a good idea to start loading an ad well in advance of
/// when it's likely to be needed.
class RewardedVideoAd {
  RewardedVideoAd._();

  /// A platform-specific AdMob test ad unit ID for rewarded video ads. This ad
  /// unit has been specially configured to always return test ads, and
  /// developers are encouraged to use it while building and testing their apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static final RewardedVideoAd _instance = RewardedVideoAd._();

  /// The one and only instance of this class.
  static RewardedVideoAd get instance => _instance;

  /// Callback invoked for events in the rewarded video ad lifecycle.
  RewardedVideoAdListener listener;

  /// Shows a rewarded video ad if one has been loaded.
  Future<bool> show() {
    return _invokeBooleanMethod("showRewardedVideoAd");
  }

  /// Loads a rewarded video ad using the provided ad unit ID.
  Future<bool> load(
      {@required String adUnitId, MobileAdTargetingInfo targetingInfo}) {
    assert(adUnitId.isNotEmpty);
    return _invokeBooleanMethod("loadRewardedVideoAd", <String, dynamic>{
      'adUnitId': adUnitId,
      'targetingInfo': targetingInfo?.toJson(),
    });
  }
}

/// Support for Google AdMob mobile ads.
///
/// Before loading or showing an ad the plugin must be initialized with
/// an AdMob app id:
/// ```
/// FirebaseAdMob.instance.initialize(appId: myAppId);
/// ```
///
/// Apps can create, load, and show mobile ads. For example:
/// ```
/// BannerAd myBanner = BannerAd(unitId: myBannerAdUnitId)
///   ..load()
///   ..show();
/// ```
///
/// See also:
///
///  * The example associated with this plugin.
///  * [BannerAd], a small rectangular ad displayed at the bottom of the screen.
///  * [InterstitialAd], a full screen ad that must be dismissed by the user.
///  * [RewardedVideoAd], a full screen video ad that provides in-app user
///    rewards.
class FirebaseAdMob {
  @visibleForTesting
  FirebaseAdMob.private(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethod);
  }

  // A placeholder AdMob App ID for testing. AdMob App IDs and ad unit IDs are
  // specific to a single operating system, so apps building for both Android and
  // iOS will need a set for each platform.
  static final String testAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';

  static final FirebaseAdMob _instance = FirebaseAdMob.private(
    const MethodChannel('plugins.flutter.io/firebase_admob'),
  );

  /// The single shared instance of this plugin.
  static FirebaseAdMob get instance => _instance;

  final MethodChannel _channel;

  static const Map<String, MobileAdEvent> _methodToMobileAdEvent =
      <String, MobileAdEvent>{
    'onAdLoaded': MobileAdEvent.loaded,
    'onAdFailedToLoad': MobileAdEvent.failedToLoad,
    'onAdClicked': MobileAdEvent.clicked,
    'onAdImpression': MobileAdEvent.impression,
    'onAdOpened': MobileAdEvent.opened,
    'onAdLeftApplication': MobileAdEvent.leftApplication,
    'onAdClosed': MobileAdEvent.closed,
  };

  static const Map<String, RewardedVideoAdEvent> _methodToRewardedVideoAdEvent =
      <String, RewardedVideoAdEvent>{
    'onRewarded': RewardedVideoAdEvent.rewarded,
    'onRewardedVideoAdClosed': RewardedVideoAdEvent.closed,
    'onRewardedVideoAdFailedToLoad': RewardedVideoAdEvent.failedToLoad,
    'onRewardedVideoAdLeftApplication': RewardedVideoAdEvent.leftApplication,
    'onRewardedVideoAdLoaded': RewardedVideoAdEvent.loaded,
    'onRewardedVideoAdOpened': RewardedVideoAdEvent.opened,
    'onRewardedVideoStarted': RewardedVideoAdEvent.started,
    'onRewardedVideoCompleted': RewardedVideoAdEvent.completed,
  };

  /// Initialize this plugin for the AdMob app specified by `appId`.
  Future<bool> initialize(
      {@required String appId,
      String trackingId,
      bool analyticsEnabled = false}) {
    assert(appId != null && appId.isNotEmpty);
    assert(analyticsEnabled != null);
    return _invokeBooleanMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    assert(call.arguments is Map);
    final Map<dynamic, dynamic> argumentsMap = call.arguments;
    final RewardedVideoAdEvent rewardedEvent =
        _methodToRewardedVideoAdEvent[call.method];
    if (rewardedEvent != null) {
      if (RewardedVideoAd.instance.listener != null) {
        if (rewardedEvent == RewardedVideoAdEvent.rewarded) {
          RewardedVideoAd.instance.listener(rewardedEvent,
              rewardType: argumentsMap['rewardType'],
              rewardAmount: argumentsMap['rewardAmount']);
        } else {
          RewardedVideoAd.instance.listener(rewardedEvent);
        }
      }
    } else {
      final int id = argumentsMap['id'];
      if (id != null && MobileAd._allAds[id] != null) {
        final MobileAd ad = MobileAd._allAds[id];
        final MobileAdEvent mobileAdEvent = _methodToMobileAdEvent[call.method];
        if (mobileAdEvent != null && ad.listener != null) {
          ad.listener(mobileAdEvent);
        }
      }
    }

    return Future<dynamic>.value(null);
  }
}

Future<bool> _invokeBooleanMethod(String method, [dynamic arguments]) async {
  // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
  // https://github.com/flutter/flutter/issues/26431
  // ignore: strong_mode_implicit_dynamic_method
  final bool result = await FirebaseAdMob.instance._channel.invokeMethod(
    method,
    arguments,
  );
  return result;
}
