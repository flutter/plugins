// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "FirebaseAdMobPlugin.h"
#import "FLTMobileAd.h"
#import "FLTRewardedVideoAdWrapper.h"
#import "Firebase/Firebase.h"

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", (long)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface FLTFirebaseAdMobPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@property(nonatomic, strong) FLTRewardedVideoAdWrapper *rewardedWrapper;
@end

@implementation FLTFirebaseAdMobPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FLTFirebaseAdMobPlugin *instance = [[FLTFirebaseAdMobPlugin alloc] init];
  instance.channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_admob"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:instance.channel];
  instance.rewardedWrapper = [[FLTRewardedVideoAdWrapper alloc] initWithChannel:instance.channel];
}

- (instancetype)init {
  self = [super init];
  if (self && ![FIRApp defaultApp]) {
    FLTLogWarning(@"[FIRApp configure]");
    [FIRApp configure];
  }
  return self;
}

- (void)dealloc {
  [self.channel setMethodCallHandler:nil];
  self.channel = nil;
}

- (void)callInitialize:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *appId = (NSString *)call.arguments[@"appId"];
  if (appId == nil || [appId length] == 0) {
    result([FlutterError errorWithCode:@"no_app_id"
                               message:@"a non-empty AdMob appId was not provided"
                               details:nil]);
    return;
  }
  [FLTMobileAd configureWithAppId:appId];
  result([NSNumber numberWithBool:YES]);
}

- (void)callLoadAd:(FLTMobileAd *)ad call:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (ad.status != CREATED) {
    if (ad.status == FAILED) {
      NSString *message = [NSString stringWithFormat:@"cannot reload a failed ad=%@", ad];
      result([FlutterError errorWithCode:@"load_failed_ad" message:message details:nil]);
    } else {
      result([NSNumber numberWithBool:YES]);  // The ad was already loaded.
    }
  }

  NSString *adUnitId = (NSString *)call.arguments[@"adUnitId"];
  if (adUnitId == nil || [adUnitId length] == 0) {
    NSString *message =
        [NSString stringWithFormat:@"a non-empty adUnitId was not provided for %@", ad];
    result([FlutterError errorWithCode:@"no_unit_id" message:message details:nil]);
    return;
  }

  NSDictionary *targetingInfo = (NSDictionary *)call.arguments[@"targetingInfo"];
  [ad loadWithAdUnitId:adUnitId targetingInfo:targetingInfo];
  result([NSNumber numberWithBool:YES]);
}

- (void)callLoadRewardedVideoAd:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (self.rewardedWrapper.status == FLTRewardedVideoAdStatusLoading ||
      self.rewardedWrapper.status == FLTRewardedVideoAdStatusLoaded) {
    result([NSNumber numberWithBool:YES]);  // The ad is loaded or about to be.
  }

  NSString *adUnitId = (NSString *)call.arguments[@"adUnitId"];
  if (adUnitId == nil || [adUnitId length] == 0) {
    result([FlutterError errorWithCode:@"no_ad_unit_id"
                               message:@"a non-empty adUnitId was not provided for rewarded video."
                               details:nil]);
    return;
  }

  NSDictionary *targetingInfo = (NSDictionary *)call.arguments[@"targetingInfo"];
  if (targetingInfo == nil) {
    result([FlutterError
        errorWithCode:@"no_targeting_info"
              message:@"a null targetingInfo object was provided for rewarded video."
              details:nil]);
    return;
  }

  [self.rewardedWrapper loadWithAdUnitId:adUnitId targetingInfo:targetingInfo];
  result([NSNumber numberWithBool:YES]);
}

- (void)callShowAd:(NSNumber *)mobileAdId
              call:(FlutterMethodCall *)call
            result:(FlutterResult)result {
  FLTMobileAd *ad = [FLTMobileAd getAdForId:mobileAdId];
  if (ad == nil) {
    NSString *message =
        [NSString stringWithFormat:@"show failed, the specified ad was not loaded id=%d",
                                   mobileAdId.intValue];
    result([FlutterError errorWithCode:@"ad_not_loaded" message:message details:nil]);
  }

  [ad show];
  result([NSNumber numberWithBool:YES]);
}

- (void)callShowRewardedVideoAd:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (self.rewardedWrapper.status != FLTRewardedVideoAdStatusLoaded) {
    result([FlutterError errorWithCode:@"ad_not_loaded"
                               message:@"show failed for rewarded video, no ad was loaded"
                               details:nil]);
    return;
  }

  [self.rewardedWrapper show];
  result([NSNumber numberWithBool:YES]);
}

- (void)callDisposeAd:(NSNumber *)mobileAdId
                 call:(FlutterMethodCall *)call
               result:(FlutterResult)result {
  FLTMobileAd *ad = [FLTMobileAd getAdForId:mobileAdId];
  if (ad == nil) {
    NSString *message =
        [NSString stringWithFormat:@"dispose failed, no ad exists for id=%d", mobileAdId.intValue];
    result([FlutterError errorWithCode:@"no_ad_for_id" message:message details:nil]);
  }

  [ad dispose];
  result([NSNumber numberWithBool:YES]);
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"initialize"]) {
    [self callInitialize:call result:result];
    return;
  }

  if ([call.method isEqualToString:@"loadRewardedVideoAd"]) {
    [self callLoadRewardedVideoAd:call result:result];
    return;
  }

  if ([call.method isEqualToString:@"showRewardedVideoAd"]) {
    [self callShowRewardedVideoAd:call result:result];
    return;
  }

  NSNumber *mobileAdId = (NSNumber *)call.arguments[@"id"];
  if (mobileAdId == nil) {
    NSString *message =
        @"FirebaseAdMobPlugin method calls for banners and "
        @"interstitials must specify an "
        @"integer mobile ad id";
    result([FlutterError errorWithCode:@"no_id" message:message details:nil]);
    return;
  }

  if ([call.method isEqualToString:@"loadBannerAd"]) {
    [self callLoadAd:[FLTBannerAd withId:mobileAdId channel:self.channel] call:call result:result];
  } else if ([call.method isEqualToString:@"loadInterstitialAd"]) {
    [self callLoadAd:[FLTInterstitialAd withId:mobileAdId channel:self.channel]
                call:call
              result:result];
  } else if ([call.method isEqualToString:@"showAd"]) {
    [self callShowAd:mobileAdId call:call result:result];
  } else if ([call.method isEqualToString:@"disposeAd"]) {
    [self callDisposeAd:mobileAdId call:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
