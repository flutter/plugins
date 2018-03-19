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
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

abstract class MobileAd extends AdListener {
  private static final String TAG = "flutter";
  private static SparseArray<MobileAd> allAds = new SparseArray<MobileAd>();

  final Activity activity;
  final MethodChannel channel;
  final int id;
  Status status;
  double anchorOffset;
  int anchorType;

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
    this.anchorOffset = 0.0;
    this.anchorType = Gravity.BOTTOM;
    allAds.put(id, this);
  }

  static Banner createBanner(Integer id, AdSize adSize, Activity activity, MethodChannel channel) {
    MobileAd ad = getAdForId(id);
    return (ad != null) ? (Banner) ad : new Banner(id, adSize, activity, channel);
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

  abstract void load(String adUnitId, Map<String, Object> targetingInfo);

  abstract void show();

  void dispose() {
    allAds.remove(id);
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
    private AdSize adSize;

    private Banner(Integer id, AdSize adSize, Activity activity, MethodChannel channel) {
      super(id, activity, channel);
      this.adSize = adSize;
    }

    @Override
    void load(String adUnitId, Map<String, Object> targetingInfo) {
      if (status != Status.CREATED) return;
      status = Status.LOADING;

      adView = new AdView(activity);
      adView.setAdSize(adSize);
      adView.setAdUnitId(adUnitId);
      adView.setAdListener(this);

      AdRequestBuilderFactory factory = new AdRequestBuilderFactory(targetingInfo);
      adView.loadAd(factory.createAdRequestBuilder().build());
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
        content.setGravity(anchorType);
        content.addView(adView);
        final float scale = activity.getResources().getDisplayMetrics().density;

        if (anchorType == Gravity.BOTTOM) {
          content.setPadding(0, 0, 0, (int) (anchorOffset * scale));
        } else {
          content.setPadding(0, (int) (anchorOffset * scale), 0, 0);
        }

        activity.addContentView(
            content,
            new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
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
    void load(String adUnitId, Map<String, Object> targetingInfo) {
      status = Status.LOADING;

      interstitial = new InterstitialAd(activity);
      interstitial.setAdUnitId(adUnitId);

      interstitial.setAdListener(this);
      AdRequestBuilderFactory factory = new AdRequestBuilderFactory(targetingInfo);
      interstitial.loadAd(factory.createAdRequestBuilder().build());
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
