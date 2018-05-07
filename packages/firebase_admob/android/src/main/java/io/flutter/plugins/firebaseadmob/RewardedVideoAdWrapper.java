// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseadmob;

import android.app.Activity;
import android.util.Log;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

public class RewardedVideoAdWrapper implements RewardedVideoAdListener {
  private static final String TAG = "flutter";

  final RewardedVideoAd rewardedInstance;
  final Activity activity;
  final MethodChannel channel;
  Status status;

  @Override
  public void onRewardedVideoAdLoaded() {
    status = Status.LOADED;
    channel.invokeMethod("onRewardedVideoAdLoaded", argumentsMap());
  }

  @Override
  public void onRewardedVideoAdOpened() {
    channel.invokeMethod("onRewardedVideoAdOpened", argumentsMap());
  }

  @Override
  public void onRewardedVideoStarted() {
    channel.invokeMethod("onRewardedVideoStarted", argumentsMap());
  }

  @Override
  public void onRewardedVideoAdClosed() {
    this.status = Status.CREATED;
    channel.invokeMethod("onRewardedVideoAdClosed", argumentsMap());
  }

  @Override
  public void onRewardedVideoCompleted() {
    channel.invokeMethod("onRewardedVideoCompleted", argumentsMap());
  }

  @Override
  public void onRewarded(RewardItem rewardItem) {
    channel.invokeMethod(
        "onRewarded",
        argumentsMap("rewardType", rewardItem.getType(), "rewardAmount", rewardItem.getAmount()));
  }

  @Override
  public void onRewardedVideoAdLeftApplication() {
    channel.invokeMethod("onRewardedVideoAdLeftApplication", argumentsMap());
  }

  @Override
  public void onRewardedVideoAdFailedToLoad(int errorCode) {
    Log.w(TAG, "onRewardedVideoAdFailedToLoad: " + errorCode);
    status = Status.FAILED;
    channel.invokeMethod("onRewardedVideoAdFailedToLoad", argumentsMap("errorCode", errorCode));
  }

  enum Status {
    CREATED,
    LOADING,
    FAILED,
    LOADED
  }

  public RewardedVideoAdWrapper(Activity activity, MethodChannel channel) {
    this.activity = activity;
    this.channel = channel;
    this.status = Status.CREATED;
    this.rewardedInstance = MobileAds.getRewardedVideoAdInstance(activity);
    this.rewardedInstance.setRewardedVideoAdListener(this);
  }

  Status getStatus() {
    return status;
  }

  public void load(String adUnitId, Map<String, Object> targetingInfo) {
    status = Status.LOADING;
    AdRequestBuilderFactory factory = new AdRequestBuilderFactory(targetingInfo);
    rewardedInstance.loadAd(adUnitId, factory.createAdRequestBuilder().build());
  }

  public void show() {
    if (rewardedInstance.isLoaded()) {
      rewardedInstance.show();
    }
  }

  private Map<String, Object> argumentsMap(Object... args) {
    Map<String, Object> arguments = new HashMap<String, Object>();
    for (int i = 0; i < args.length; i += 2) arguments.put(args[i].toString(), args[i + 1]);
    return arguments;
  }
}
