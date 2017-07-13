// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.util.Log;
import android.util.SparseArray;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

abstract class MobileAd extends AdListener {
  private static final String TAG = "flutter";
  private static SparseArray<MobileAd> allAds = new SparseArray<MobileAd>();

  final Activity activity;
  final MethodChannel channel;
  final int id;
  Status status;

  enum Status {
    CREATED,
    LOADING,
    FAILED,
    PENDING, // The ad will be shown when status is changed to LOADED.
    LOADED,
  }

  private MobileAd(int id, Activity activity, MethodChannel channel) {
    this.id = id;
    this.activity = activity;
    this.channel = channel;
    this.status = Status.CREATED;
    allAds.put(id, this);
  }

  static Banner createBanner(Integer id, Activity activity, MethodChannel channel) {
    MobileAd ad = getAdForId(id);
    return (ad != null) ? (Banner) ad : new Banner(id, activity, channel);
  }

  static Interstitial createInterstitial(Integer id, Activity activity, MethodChannel channel) {
    MobileAd ad = getAdForId(id);
    return (ad != null) ? (Interstitial) ad : new Interstitial(id, activity, channel);
  }

  static MobileAd getAdForId(Integer id) {
    return allAds.get(id);
  }

  Status getStatus() {
    return status;
  }

  abstract void load(String unitId, Map<String, Object> targetingInfo);

  abstract void show();

  void dispose() {
    allAds.remove(id);
  }

  private String getTargetingInfoString(String key, Object value) {
    if (value == null) return null;
    if (!(value instanceof String)) {
      Log.w(TAG, "targeting info " + key + ": expected a String, mobileAdId=" + id);
      return null;
    }
    String stringValue = (String) value;
    if (stringValue.isEmpty()) {
      Log.w(TAG, "targeting info " + key + ": expected a non-empty String, mobileAdId=" + id);
      return null;
    }
    return stringValue;
  }

  private Boolean getTargetingInfoBoolean(String key, Object value) {
    if (value == null) return null;
    if (!(value instanceof Boolean)) {
      Log.w(TAG, "targeting info " + key + ": expected a boolean, mobileAdId=" + id);
      return null;
    }
    return (Boolean) value;
  }

  private Integer getTargetingInfoInteger(String key, Object value) {
    if (value == null) return null;
    if (!(value instanceof Integer)) {
      Log.w(TAG, "targeting info " + key + ": expected an integer, mobileAdId=" + id);
      return null;
    }
    return (Integer) value;
  }

  private ArrayList getTargetingInfoArrayList(String key, Object value) {
    if (value == null) return null;
    if (!(value instanceof ArrayList)) {
      Log.w(TAG, "targeting info " + key + ": expected an ArrayList, mobileAdId=" + id);
      return null;
    }
    return (ArrayList) value;
  }

  AdRequest.Builder createAdRequestBuilder(Map<String, Object> info) {
    AdRequest.Builder builder = new AdRequest.Builder();
    if (info == null) return builder;

    ArrayList testDevices = getTargetingInfoArrayList("testDevices", info.get("testDevices"));
    if (testDevices != null) {
      for (Object deviceValue : testDevices) {
        String device = getTargetingInfoString("testDevices element", deviceValue);
        if (device != null) builder.addTestDevice(device);
      }
    }

    ArrayList keywords = getTargetingInfoArrayList("keywords", info.get("keywords"));
    if (keywords != null) {
      for (Object keywordValue : keywords) {
        String keyword = getTargetingInfoString("keywords element", keywordValue);
        if (keyword != null) builder.addKeyword(keyword);
      }
    }

    String contentUrl = getTargetingInfoString("contentUrl", info.get("contentUrl"));
    if (contentUrl != null) builder.setContentUrl(contentUrl);

    Object birthday = info.get("birthday");
    if (birthday != null) {
      if (!(birthday instanceof Long))
        Log.w(TAG, "targeting info birthday: expected a long integer, mobileAdId=" + id);
      else builder.setBirthday(new Date((Long) birthday));
    }

    Integer gender = getTargetingInfoInteger("gender", info.get("gender"));
    if (gender != null) {
      switch (gender.intValue()) {
        case 0: // MobileAdGender.unknown
        case 1: // MobileAdGender.male
        case 2: // MobileAdGender.female
          builder.setGender(gender.intValue());
          break;
        default:
          Log.w(TAG, "targeting info gender: invalid value, mobileAdId=" + id);
      }
    }

    Boolean designedForFamilies =
        getTargetingInfoBoolean("designedForFamilies", info.get("designedForFamilies"));
    if (designedForFamilies != null) builder.setIsDesignedForFamilies(designedForFamilies);

    Boolean childDirected = getTargetingInfoBoolean("childDirected", info.get("childDirected"));
    if (childDirected != null) builder.tagForChildDirectedTreatment(childDirected);

    String requestAgent = getTargetingInfoString("requestAgent", info.get("requestAgent"));
    if (requestAgent != null) builder.setRequestAgent(requestAgent);

    return builder;
  }

  private Map<String, Object> argumentsMap(Object... args) {
    Map<String, Object> arguments = new HashMap<String, Object>();
    arguments.put("id", id);
    for (int i = 0; i < args.length; i += 2) arguments.put(args[i].toString(), args[i + 1]);
    return arguments;
  }

  @Override
  public void onAdLoaded() {
    boolean statusWasPending = status == Status.PENDING;
    status = Status.LOADED;
    channel.invokeMethod("onAdLoaded", argumentsMap());
    if (statusWasPending) show();
  }

  @Override
  public void onAdFailedToLoad(int errorCode) {
    Log.w(TAG, "onAdFailedToLoad: " + errorCode);
    status = Status.FAILED;
    channel.invokeMethod("onAdFailedToLoad", argumentsMap("errorCode", errorCode));
  }

  @Override
  public void onAdOpened() {
    channel.invokeMethod("onAdOpened", argumentsMap());
  }

  @Override
  public void onAdClicked() {
    channel.invokeMethod("onAdClicked", argumentsMap());
  }

  @Override
  public void onAdImpression() {
    channel.invokeMethod("onAdImpression", argumentsMap());
  }

  @Override
  public void onAdLeftApplication() {
    channel.invokeMethod("onAdLeftApplication", argumentsMap());
  }

  @Override
  public void onAdClosed() {
    channel.invokeMethod("onAdClosed", argumentsMap());
  }

  static class Banner extends MobileAd {
    private AdView adView;

    private Banner(Integer id, Activity activity, MethodChannel channel) {
      super(id, activity, channel);
    }

    @Override
    void load(String unitId, Map<String, Object> targetingInfo) {
      if (status != Status.CREATED) return;
      status = Status.LOADING;

      adView = new AdView(activity);
      adView.setAdSize(AdSize.SMART_BANNER);
      adView.setAdUnitId(unitId);
      adView.setAdListener(this);

      AdRequest.Builder adRequestBuilder = createAdRequestBuilder(targetingInfo);
      adView.loadAd(adRequestBuilder.build());
    }

    @Override
    void show() {
      if (status == Status.LOADING) {
        status = Status.PENDING;
        return;
      }
      if (status != Status.LOADED) return;

      if (activity.findViewById(id) == null) {
        LinearLayout content = new LinearLayout(activity);
        content.setId(id);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setGravity(Gravity.BOTTOM);
        content.addView(adView);

        activity.addContentView(
            content,
            new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.MATCH_PARENT));
      }
    }

    @Override
    void dispose() {
      super.dispose();

      View contentView = activity.findViewById(id);
      if (contentView == null || !(contentView.getParent() instanceof ViewGroup)) return;

      adView.destroy();

      ViewGroup contentParent = (ViewGroup) (contentView.getParent());
      contentParent.removeView(contentView);
    }
  }

  static class Interstitial extends MobileAd {
    private InterstitialAd interstitial = null;

    private Interstitial(int id, Activity activity, MethodChannel channel) {
      super(id, activity, channel);
    }

    @Override
    void load(String unitId, Map<String, Object> targetingInfo) {
      status = Status.LOADING;

      interstitial = new InterstitialAd(activity);
      interstitial.setAdUnitId(unitId);

      AdRequest.Builder adRequestBuilder = createAdRequestBuilder(targetingInfo);
      interstitial.setAdListener(this);
      interstitial.loadAd(adRequestBuilder.build());
    }

    @Override
    void show() {
      if (status == Status.LOADING) {
        status = Status.PENDING;
        return;
      }
      interstitial.show();
    }

    // It is not possible to hide/remove/destroy an AdMob interstitial Ad.
  }
}
