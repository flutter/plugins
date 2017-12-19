// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.widget.LinearLayout;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.firebase.FirebaseApp;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.util.Map;

public class FirebaseAdMobPlugin implements MethodCallHandler {
  private static final String TAG = "flutter";

  private final Registrar registrar;
  private final MethodChannel channel;

  private LinearLayout banner;
  InterstitialAd interstitial;

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_admob");
    channel.setMethodCallHandler(new FirebaseAdMobPlugin(registrar, channel));
  }

  private FirebaseAdMobPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.channel = channel;
    FirebaseApp.initializeApp(registrar.context());
  }

  private void callInitialize(MethodCall call, Result result) {
    String appId = call.argument("appId");
    if (appId == null || appId.isEmpty()) {
      result.error("no_app_id", "a non-empty AdMob appId was not provided", null);
      return;
    }
    MobileAds.initialize(registrar.context(), appId);
    result.success(Boolean.TRUE);
  }

  private void callLoadAd(MobileAd ad, MethodCall call, Result result) {
    if (ad.status != MobileAd.Status.CREATED) {
      if (ad.status == MobileAd.Status.FAILED)
        result.error("load_failed_ad", "cannot reload a failed ad, id=" + ad.id, null);
      else result.success(Boolean.TRUE); // The ad was already loaded.
      return;
    }

    String unitId = call.argument("unitId");
    if (unitId == null || unitId.isEmpty()) {
      result.error("no_unit_id", "a non-empty unitId was not provided for ad id=" + ad.id, null);
      return;
    }
    Map<String, Object> targetingInfo = call.argument("targetingInfo");
    ad.load(unitId, targetingInfo);
    result.success(Boolean.TRUE);
  }

  private void callShowAd(int id, MethodCall call, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("ad_not_loaded", "show failed, the specified ad was not loaded id=" + id, null);
      return;
    }
    ad.show();
    result.success(Boolean.TRUE);
  }

  private void callDisposeAd(int id, MethodCall call, Result result) {
    MobileAd ad = MobileAd.getAdForId(id);
    if (ad == null) {
      result.error("no_ad_for_id", "dispose failed, no add exists for id=" + id, null);
      return;
    }

    ad.dispose();
    result.success(Boolean.TRUE);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("initialize")) {
      callInitialize(call, result);
      return;
    }

    Activity activity = registrar.activity();
    if (activity == null) {
      result.error("no_activity", "firebase_admob plugin requires a foreground activity", null);
      return;
    }

    Integer id = call.argument("id");
    if (id == null) {
      result.error(
          "no_id",
          "all FirebaseAdMobPlugin method calls must specify an integer mobile ad id",
          null);
      return;
    }

    switch (call.method) {
      case "loadBannerAd":
        callLoadAd(MobileAd.createBanner(id, activity, channel), call, result);
        break;
      case "loadInterstitialAd":
        callLoadAd(MobileAd.createInterstitial(id, activity, channel), call, result);
        break;
      case "showAd":
        callShowAd(id, call, result);
        break;
      case "disposeAd":
        callDisposeAd(id, call, result);
        break;
      default:
        result.notImplemented();
    }
  }
}
