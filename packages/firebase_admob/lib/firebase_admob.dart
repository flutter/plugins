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
  const MobileAdTargetingInfo({
    this.keywords,
    this.contentUrl,
    this.birthday,
    this.gender,
    this.designedForFamilies,
    this.childDirected,
    this.testDevices,
  });

  final List<String> keywords;
  final String contentUrl;
  final DateTime birthday;
  final MobileAdGender gender;
  final bool designedForFamilies;
  final bool childDirected;
  final List<String> testDevices;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'requestAgent': 'flutter-alpha',
    };

    if (keywords != null && keywords.isNotEmpty) {
      assert(keywords.every((String s) => s != null && s.isNotEmpty));
      json['keywords'] = keywords;
    }
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

/// A mobile [BannerAd] or [InterstitialAd] for the [FirebaseAdMobPlugin].
///
/// A [MobileAd] must be loaded with [load] before it is shown with [show].
///
/// A valid [adUnitId] is required.
abstract class MobileAd {
  static final Map<int, MobileAd> _allAds = <int, MobileAd>{};

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

  /// Optional targeting info per the native AdMob API.
  MobileAdTargetingInfo get targetingInfo => _targetingInfo;
  final MobileAdTargetingInfo _targetingInfo;

  /// Identifies the source of ads for your application.
  ///
  /// For testing use a [sample ad unit](https://developers.google.com/admob/ios/test-ads#sample_ad_units).
  final String adUnitId;

  /// Called when the status of the ad changes.
  final MobileAdListener listener;

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
  Future<bool> show() {
    return _invokeBooleanMethod("showAd", <String, dynamic>{'id': id});
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

  Future<bool> _doLoad(String loadMethod) {
    return _invokeBooleanMethod(loadMethod, <String, dynamic>{
      'id': id,
      'adUnitId': adUnitId,
      'targetingInfo': targetingInfo?.toJson(),
    });
  }
}

/// A banner ad for the [FirebaseAdMobPlugin].
class BannerAd extends MobileAd {
  /// These are AdMob's test ad unit IDs, which always return test ads. You're
  /// encouraged to use them for testing in your own apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  /// Create a BannerAd.
  ///
  /// A valid [adUnitId] is required.
  BannerAd({
    @required String adUnitId,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  })
      : super(
            adUnitId: adUnitId,
            targetingInfo: targetingInfo,
            listener: listener);

  @override
  Future<bool> load() => _doLoad("loadBannerAd");
}

/// A full-screen interstitial ad for the [FirebaseAdMobPlugin].
class InterstitialAd extends MobileAd {
  /// A platform-specific AdMob test ad unit ID for interstitials. This ad unit
  /// has been specially configured to always return test ads, and developers
  /// are encouraged to use it while building and testing their apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  /// Create an Interstitial.
  ///
  /// A valid [adUnitId] is required.
  InterstitialAd({
    String adUnitId,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  })
      : super(
            adUnitId: adUnitId,
            targetingInfo: targetingInfo,
            listener: listener);

  @override
  Future<bool> load() => _doLoad("loadInterstitialAd");
}

/// [RewardedVideoAd] status changes reported to [RewardedVideoAdListener]s.
///
/// The [rewarded] event is particularly important, since it indicates that the
/// user has watched a video to completion and should be given an in-app reward.
enum RewardedVideoAdEvent {
  loaded,
  failedToLoad,
  opened,
  leftApplication,
  closed,
  rewarded,
  started,
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
  /// A platform-specific AdMob test ad unit ID for rewarded video ads. This ad
  /// unit has been specially configured to always return test ads, and
  /// developers are encouraged to use it while building and testing their apps.
  static final String testAdUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

  static final RewardedVideoAd _instance = new RewardedVideoAd._();

  RewardedVideoAd._();

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
/// BannerAd myBanner = new BannerAd(unitId: myBannerAdUnitId)
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
  // A placeholder AdMob App ID for testing. AdMob App IDs and ad unit IDs are
  // specific to a single operating system, so apps building for both Android and
  // iOS will need a set for each platform.
  static final String testAppId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544~3347511713'
      : 'ca-app-pub-3940256099942544~1458002511';

  @visibleForTesting
  FirebaseAdMob.private(MethodChannel channel) : _channel = channel {
    _channel.setMethodCallHandler(_handleMethod);
  }

  static final FirebaseAdMob _instance = new FirebaseAdMob.private(
    const MethodChannel('plugins.flutter.io/firebase_admob'),
  );

  /// The single shared instance of this plugin.
  static FirebaseAdMob get instance => _instance;

  final MethodChannel _channel;

  static const Map<String, MobileAdEvent> _methodToMobileAdEvent =
      const <String, MobileAdEvent>{
    'onAdLoaded': MobileAdEvent.loaded,
    'onAdFailedToLoad': MobileAdEvent.failedToLoad,
    'onAdClicked': MobileAdEvent.clicked,
    'onAdImpression': MobileAdEvent.impression,
    'onAdOpened': MobileAdEvent.opened,
    'onAdLeftApplication': MobileAdEvent.leftApplication,
    'onAdClosed': MobileAdEvent.closed,
  };

  static const Map<String, RewardedVideoAdEvent> _methodToRewardedVideoAdEvent =
      const <String, RewardedVideoAdEvent>{
    'onRewarded': RewardedVideoAdEvent.rewarded,
    'onRewardedVideoAdClosed': RewardedVideoAdEvent.closed,
    'onRewardedVideoAdFailedToLoad': RewardedVideoAdEvent.failedToLoad,
    'onRewardedVideoAdLeftApplication': RewardedVideoAdEvent.leftApplication,
    'onRewardedVideoAdLoaded': RewardedVideoAdEvent.loaded,
    'onRewardedVideoAdOpened': RewardedVideoAdEvent.opened,
    'onRewardedVideoStarted': RewardedVideoAdEvent.started,
  };

  /// Initialize this plugin for the AdMob app specified by `appId`.
  Future<bool> initialize(
      {@required String appId,
      String trackingId,
      bool analyticsEnabled: false}) {
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
    final Map<String, dynamic> argumentsMap = call.arguments;
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

    return new Future<Null>(null);
  }
}

Future<bool> _invokeBooleanMethod(String method, [dynamic arguments]) async {
  final bool result = await FirebaseAdMob.instance._channel.invokeMethod(
    method,
    arguments,
  );
  return result;
}
