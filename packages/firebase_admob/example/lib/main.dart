// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

// A placeholder AdMob App Id for testing. AdMob App IDs and ad unit IDs are
// specific to a single operating system, so apps building for both Android and
// iOS will need a set for each platform.
const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
const String iOSAppId = 'ca-app-pub-3940256099942544~1458002511';

// These are AdMob's test ad unit IDs, which always return test ads. You're
// encouraged to use them for testing in your own apps.
const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String androidInterstitialAdUnitId =
    'ca-app-pub-3940256099942544/1033173712';
const String iOSBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
const String iOSInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';

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

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  BannerAd createBannerAd() {
    return new BannerAd(
      unitId: Platform.isAndroid ? androidBannerAdUnitId : iOSBannerAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return new InterstitialAd(
      unitId: Platform.isAndroid
          ? androidInterstitialAdUnitId
          : iOSInterstitialAdUnitId,
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
        .initialize(appId: Platform.isAndroid ? androidAppId : iOSAppId);
    _bannerAd = createBannerAd()..load();
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
