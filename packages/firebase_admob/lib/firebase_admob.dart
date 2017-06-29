// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

enum MobileAdEvent {
  loaded,
  failedToLoad,
  clicked,
  impression,
  opened,
  leftApplication,
  closed,
}

typedef void MobileAdListener(MobileAdEvent event);

class MobileAdTargetingInfo {
  const MobileAdTargetingInfo({
    this.keywords,
    this.contentUrl,
    this.birthday,
    this.gender,
    this.designedForFamilies,
    this.childDirected,
    this.testDevices,
    this.requestAgent,
  });

  final List<String> keywords;
  final String contentUrl;
  final DateTime birthday;
  final String gender;
  final bool designedForFamilies;
  final bool childDirected;
  final List<String> testDevices;
  final String requestAgent;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    if (keywords != null && keywords.isNotEmpty) {
      assert(keywords.every((String s) => s != null && s.isNotEmpty));
      json['keywords'] = keywords;
    }
    if (contentUrl != null && contentUrl.isNotEmpty)
      json['contentUrl'] = contentUrl;
    if (birthday != null)
      json['birthday'] = birthday.millisecondsSinceEpoch;
    if (gender != null && gender.isNotEmpty)
      json[gender] = gender;
    if (designedForFamilies != null)
      json['designedForFamilies'] = designedForFamilies;
    if (childDirected != null)
      json['childDirected'] = childDirected;
    if (testDevices != null && testDevices.isNotEmpty) {
      assert(testDevices.every((String s) => s != null && s.isNotEmpty));
      json['testDevices'] = testDevices;
    }
    if (requestAgent != null && requestAgent.isNotEmpty)
      json['requestAgent'] = requestAgent;

    return json;
  }
}

abstract class MobileAd {
  static final Map<int, MobileAd> _allAds = <int, MobileAd>{};

  MobileAd({ this.unitId, this.targetingInfo, this.listener }) {
    assert(unitId != null && unitId.isNotEmpty);
    assert(_allAds[id] == null);
    _allAds[id] = this;
  }

  final MobileAdTargetingInfo targetingInfo;
  final String unitId;
  final MobileAdListener listener;

  int get id => hashCode;

  MethodChannel get _channel => FirebaseAdMob.instance._channel;

  Future<bool> load();

  Future<bool> show() {
    return _channel.invokeMethod("showAd", <String, dynamic>{'id': id});
  }

  Future<bool> dispose() {
    assert(_allAds[id] != null);
    _allAds[id] = null;
    return _channel.invokeMethod("disposeAd", <String, dynamic>{'id': id});
  }

  Future<bool> _doLoad(String loadMethod) {
    return _channel.invokeMethod(loadMethod, <String, dynamic>{
      'id': id,
      'unitId': unitId,
      'targetingInfo': targetingInfo?.toJson(),
    });
  }
}

class BannerAd extends MobileAd {
  BannerAd({
    String unitId,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  }) : super(unitId: unitId, targetingInfo: targetingInfo, listener: listener);

  @override
  Future<bool> load() => _doLoad("loadBannerAd");
}

class InterstitialAd extends MobileAd {
  InterstitialAd({
    String unitId,
    MobileAdTargetingInfo targetingInfo,
    MobileAdListener listener,
  }) : super(unitId: unitId, targetingInfo: targetingInfo, listener: listener);

  @override
  Future<bool> load() => _doLoad("loadInterstitialAd");
}

class FirebaseAdMob {
  static const Map<String, MobileAdEvent> _methodToEvent = const <String, MobileAdEvent> {
    'onAdLoaded': MobileAdEvent.loaded,
    'onAdFailedToLoad': MobileAdEvent.failedToLoad,
    'onAdClicked': MobileAdEvent.clicked,
    'onAdImpression': MobileAdEvent.impression,
    'onAdOpened': MobileAdEvent.opened,
    'onAdLeftApplication': MobileAdEvent.leftApplication,
    'onAdClosed': MobileAdEvent.closed,
  };

  static final FirebaseAdMob _instance = new FirebaseAdMob.private(
    const MethodChannel('firebase_admob'),
    const LocalPlatform(),
  );

  static FirebaseAdMob get instance => _instance;

  @visibleForTesting
  FirebaseAdMob.private(MethodChannel channel, Platform platform)
      : _channel = channel, _platform = platform {
    _channel.setMethodCallHandler(_handleMethod);
  }

  final MethodChannel _channel;
  final Platform _platform;

  Future<bool> initialize({ String appId, String trackingId, bool analyticsEnabled }) {
    return _channel.invokeMethod("initialize", <String, dynamic>{
      'appId': appId,
      'trackingId': trackingId,
      'analyticsEnabled': analyticsEnabled,
    });
  }

  Future<dynamic> _handleMethod(MethodCall call) {
    assert(call.arguments is Map);
    final Map<String, dynamic> argumentsMap = call.arguments;
    final int id = argumentsMap['id'];
    if (id != null && MobileAd._allAds[id] != null) {
      final MobileAd ad = MobileAd._allAds[id];
      final MobileAdEvent event = _methodToEvent[call.method];
      if (event != null && ad.listener != null)
        ad.listener(event);
    }

    return new Future<Null>(null);
  }
}
