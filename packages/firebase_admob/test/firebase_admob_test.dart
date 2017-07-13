// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:test/test.dart';

void main() {
  group('FirebaseAdMob', () {
    const MethodChannel channel =
        const MethodChannel('plugins.flutter.io/firebase_admob');

    const String appId = 'ca-app-pub-3940256099942544~3347511713';
    const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
    const String interstitialAdUnitId =
        'ca-app-pub-3940256099942544/1033173712';

    final List<MethodCall> log = <MethodCall>[];
    final FirebaseAdMob admob = new FirebaseAdMob.private(channel);

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'initialize':
          case 'loadBannerAd':
          case 'loadInterstitialAd':
          case 'showAd':
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
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('initialize', <String, dynamic>{
              'appId': appId,
              'trackingId': null,
              'analyticsEnabled': false,
            }),
          ]));
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

      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('loadBannerAd', <String, dynamic>{
              'id': id,
              'unitId': bannerAdUnitId,
              'targetingInfo': null,
            }),
            new MethodCall('showAd', <String, dynamic>{
              'id': id,
            }),
            new MethodCall('disposeAd', <String, dynamic>{
              'id': id,
            }),
          ]));
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

      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('loadInterstitialAd', <String, dynamic>{
              'id': id,
              'unitId': interstitialAdUnitId,
              'targetingInfo': null,
            }),
            new MethodCall('showAd', <String, dynamic>{
              'id': id,
            }),
            new MethodCall('disposeAd', <String, dynamic>{
              'id': id,
            }),
          ]));
    });
  });
}
