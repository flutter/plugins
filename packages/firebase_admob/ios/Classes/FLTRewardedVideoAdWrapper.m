// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTRewardedVideoAdWrapper.h"
#import "FLTRequestFactory.h"
#import "FirebaseAdMobPlugin.h"

static NSDictionary *rewardedStatusToString = nil;

@interface FLTRewardedVideoAdWrapper () <GADRewardBasedVideoAdDelegate>
@end

@implementation FLTRewardedVideoAdWrapper

FlutterMethodChannel *_rewardedChannel;
FLTRewardedVideoAdStatus _rewardedStatus;

+ (void)initialize {
  if (rewardedStatusToString == nil) {
    rewardedStatusToString = @{
      @(FLTRewardedVideoAdStatusCreated) : @"CREATED",
      @(FLTRewardedVideoAdStatusLoading) : @"LOADING",
      @(FLTRewardedVideoAdStatusFailed) : @"FAILED",
      @(FLTRewardedVideoAdStatusLoaded) : @"LOADED"
    };
  }
}

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _rewardedChannel = channel;
    _rewardedStatus = FLTRewardedVideoAdStatusCreated;
    [GADRewardBasedVideoAd sharedInstance].delegate = self;
  }
  return self;
}

- (FLTRewardedVideoAdStatus)status {
  return _rewardedStatus;
}

- (void)loadWithAdUnitId:(NSString *)adUnitId targetingInfo:(NSDictionary *)targetingInfo {
  if (_rewardedStatus != FLTRewardedVideoAdStatusCreated &&
      _rewardedStatus != FLTRewardedVideoAdStatusFailed) {
    return;
  }

  _rewardedStatus = FLTRewardedVideoAdStatusLoading;
  FLTRequestFactory *factory = [[FLTRequestFactory alloc] initWithTargetingInfo:targetingInfo];
  [[GADRewardBasedVideoAd sharedInstance] loadRequest:[factory createRequest]
                                         withAdUnitID:adUnitId];
}

- (void)show {
  [[GADRewardBasedVideoAd sharedInstance]
      presentFromRootViewController:[FLTRewardedVideoAdWrapper rootViewController]];
}

- (NSString *)description {
  NSString *statusString =
      (NSString *)rewardedStatusToString[[NSNumber numberWithInt:_rewardedStatus]];
  return [NSString
      stringWithFormat:@"%@ %@ FLTRewardedVideoAdWrapper", super.description, statusString];
}

- (void)rewardBasedVideoAd:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd
    didRewardUserWithReward:(nonnull GADAdReward *)reward {
  NSDictionary *arguments = @{
    @"rewardAmount" : [NSNumber numberWithInt:[reward.amount intValue]],
    @"rewardType" : reward.type
  };
  [_rewardedChannel invokeMethod:@"onRewarded" arguments:arguments];
}

- (void)rewardBasedVideoAd:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd
    didFailToLoadWithError:(nonnull NSError *)error {
  NSLog(@"interstitial:didFailToReceiveAdWithError: %@ (MobileAd %@)", [error localizedDescription],
        self);
  _rewardedStatus = FLTRewardedVideoAdStatusFailed;
  [_rewardedChannel invokeMethod:@"onRewardedVideoAdFailedToLoad" arguments:@{}];
}

- (void)rewardBasedVideoAdDidReceiveAd:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  _rewardedStatus = FLTRewardedVideoAdStatusLoaded;
  [_rewardedChannel invokeMethod:@"onRewardedVideoAdLoaded" arguments:@{}];
}

- (void)rewardBasedVideoAdDidOpen:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [_rewardedChannel invokeMethod:@"onRewardedVideoAdOpened" arguments:@{}];
}

- (void)rewardBasedVideoAdDidStartPlaying:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [_rewardedChannel invokeMethod:@"onRewardedVideoStarted" arguments:@{}];
}

- (void)rewardBasedVideoAdDidCompletePlaying:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [_rewardedChannel invokeMethod:@"onRewardedVideoCompleted" arguments:@{}];
}

- (void)rewardBasedVideoAdDidClose:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [_rewardedChannel invokeMethod:@"onRewardedVideoAdClosed" arguments:@{}];
  _rewardedStatus = FLTRewardedVideoAdStatusCreated;
}

- (void)rewardBasedVideoAdWillLeaveApplication:(nonnull GADRewardBasedVideoAd *)rewardBasedVideoAd {
  [_rewardedChannel invokeMethod:@"onRewardedVideoAdLeftApplication" arguments:@{}];
}

@end
