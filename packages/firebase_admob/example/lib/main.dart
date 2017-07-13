// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';

// A placeholder AdMob App Id for testing.
const String appId = 'ca-app-pub-3940256099942544~3347511713';

// Specify this to quiet Android log messages that say:
//   Use AdRequest.Builder.addTestDevice("...") to get test ads on this device.
//const String testDevice = null;
const String testDevice = '33B6FA56617D7688A3A466295DED82BE';

// See https://developers.google.com/admob/ios/test-ads
const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

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
      unitId: bannerAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("BannerAd event $event");
      },
    );
  }

  InterstitialAd createInterstitialAd() {
    return new InterstitialAd(
      unitId: interstitialAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
      },
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: appId);
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
                child: const Text('SHOW INTERSTITIAL'),
                onPressed: () {
                  _interstitialAd?.dispose();
                  _interstitialAd = createInterstitialAd()
                    ..load()
                    ..show();
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
