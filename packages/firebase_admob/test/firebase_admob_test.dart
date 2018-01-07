// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseAdMob', () {
    const MethodChannel channel =
        const MethodChannel('plugins.flutter.io/firebase_admob');

    // Platform-specific App IDs that can be used for testing.
    const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
    const String iOSAppId = 'ca-app-pub-3940256099942544~1458002511';

    // Platform-specific ad unit IDs that always return test ads.
    const String androidBannerAdUnitId =
        'ca-app-pub-3940256099942544/6300978111';
    const String androidInterstitialAdUnitId =
        'ca-app-pub-3940256099942544/1033173712';
    const String androidRewardedVideoAdUnitId =
        'ca-app-pub-3940256099942544/5224354917';
    const String iOSBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
    const String iOSInterstitialAdUnitId =
        'ca-app-pub-3940256099942544/4411468910';
    const String iOSRewardedVideoAdUnitId =
        'ca-app-pub-3940256099942544/1712485313';

    final String appId = Platform.isAndroid ? androidAppId : iOSAppId;
    final String bannerAdUnitId =
        Platform.isAndroid ? androidBannerAdUnitId : iOSBannerAdUnitId;
    final String interstitialAdUnitId = Platform.isAndroid
        ? androidInterstitialAdUnitId
        : iOSInterstitialAdUnitId;
    final String rewardedVideoAdUnitId = Platform.isAndroid
        ? androidRewardedVideoAdUnitId
        : iOSRewardedVideoAdUnitId;

    final List<MethodCall> log = <MethodCall>[];
    final FirebaseAdMob admob = new FirebaseAdMob.private(channel);

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
          case 'loadBannerAd':
          case 'loadInterstitialAd':
          case 'loadRewardedVideoAd':
          case 'showAd':
          case 'showRewardedVideoAd':
          case 'disposeAd':
            return new Future<bool>.value(true);
          default:
            assert(false);
        }
      });
    });

    test('initialize', () async {
      log.clear();

      expect(await admob.initialize(appId: appId), true);
      expect(log, <Matcher>[
        isMethodCall('initialize', arguments: <String, dynamic>{
          'appId': appId,
          'trackingId': null,
          'analyticsEnabled': false,
        }),
      ]);
    });

    test('banner', () async {
      log.clear();

      final BannerAd banner = new BannerAd(
        unitId: bannerAdUnitId,
      );
      final int id = banner.id;

      expect(await banner.load(), true);
      expect(await banner.show(), true);
      expect(await banner.dispose(), true);

      expect(log, <Matcher>[
        isMethodCall('loadBannerAd', arguments: <String, dynamic>{
          'id': id,
          'unitId': bannerAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
        }),
        isMethodCall('showAd', arguments: <String, dynamic>{
          'id': id,
        }),
        isMethodCall('disposeAd', arguments: <String, dynamic>{
          'id': id,
        }),
      ]);
    });

    test('interstitial', () async {
      log.clear();

      final InterstitialAd interstitial = new InterstitialAd(
        unitId: interstitialAdUnitId,
      );
      final int id = interstitial.id;

      expect(await interstitial.load(), true);
      expect(await interstitial.show(), true);
      expect(await interstitial.dispose(), true);

      expect(log, <Matcher>[
        isMethodCall('loadInterstitialAd', arguments: <String, dynamic>{
          'id': id,
          'unitId': interstitialAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
        }),
        isMethodCall('showAd', arguments: <String, dynamic>{
          'id': id,
        }),
        isMethodCall('disposeAd', arguments: <String, dynamic>{
          'id': id,
        }),
      ]);
    });

    test('rewarded', () async {
      log.clear();

      expect(
          await RewardedVideoAd.instance
              .load(rewardedVideoAdUnitId, const MobileAdTargetingInfo()),
          true);

      expect(await RewardedVideoAd.instance.show(), true);

      expect(log, <Matcher>[
        isMethodCall('loadRewardedVideoAd', arguments: <String, dynamic>{
          'adUnitId': rewardedVideoAdUnitId,
          'targetingInfo': <String, String>{'requestAgent': 'flutter-alpha'},
        }),
        isMethodCall('showRewardedVideoAd', arguments: null),
      ]);
    });
  });
}
