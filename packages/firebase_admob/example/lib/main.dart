// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

// You can also test with your own ad unit IDs by registering your device as a
// test device. Check the logs for your device's ID value.
const String testDevice = 'YOUR_DEVICE_ID';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: testDevice != null ? <String>[testDevice] : null,
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    birthday: new DateTime.now(),
    childDirected: true,
    gender: MobileAdGender.male,
  );

  static final String _appId =
      Platform.isAndroid ? androidTestAppId : iOSTestAppId;
  static final String _bannerAdUnitId =
      Platform.isAndroid ? androidBannerTestAdUnitId : iOSBannerTestAdUnitId;
  static final String _interstitialAdUnitId = Platform.isAndroid
      ? androidInterstitialTestAdUnitId
      : iOSInterstitialTestAdUnitId;
  static final String _rewardedVideoAdUnitId = Platform.isAndroid
      ? androidRewardedVideoTestAdUnitId
      : iOSRewardedVideoTestAdUnitId;

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;
  int _coins = 0;

  BannerAd createBannerAd() {
    return new BannerAd(
      unitId: _bannerAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return new InterstitialAd(
      unitId: _interstitialAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: _appId);
    _bannerAd = createBannerAd()..load();
    RewardedVideoAd.instance.listener =
        (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      print("RewardedVideoAd event $event");
      if (event == RewardedVideoAdEvent.rewarded) {
        setState(() {
          _coins += rewardAmount;
        });
      }
    };
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('AdMob Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new RaisedButton(
                  child: const Text('SHOW BANNER'),
                  onPressed: () {
                    _bannerAd ??= createBannerAd();
                    _bannerAd
                      ..load()
                      ..show();
                  }),
              new RaisedButton(
                  child: const Text('REMOVE BANNER'),
                  onPressed: () {
                    _bannerAd?.dispose();
                    _bannerAd = null;
                  }),
              new RaisedButton(
                child: const Text('LOAD INTERSTITIAL'),
                onPressed: () {
                  _interstitialAd?.dispose();
                  _interstitialAd = createInterstitialAd()..load();
                },
              ),
              new RaisedButton(
                child: const Text('SHOW INTERSTITIAL'),
                onPressed: () {
                  _interstitialAd?.show();
                },
              ),
              new RaisedButton(
                child: const Text('LOAD REWARDED VIDEO'),
                onPressed: () {
                  RewardedVideoAd.instance.load(
                      adUnitId: _rewardedVideoAdUnitId,
                      targetingInfo: targetingInfo);
                },
              ),
              new RaisedButton(
                child: const Text('SHOW REWARDED VIDEO'),
                onPressed: () {
                  RewardedVideoAd.instance.show();
                },
              ),
              new Text("You have $_coins coins."),
            ].map((Widget button) {
              return new Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: button,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(new MyApp());
}
