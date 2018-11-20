// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "FirebaseAdMobPlugin.h"

#import <UIKit/UIKit.h>

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

- (void)callLoadBannerAdWithId:(NSNumber *)id
                       channel:(FlutterMethodChannel *)channel
                          call:(FlutterMethodCall *)call
                        result:(FlutterResult)result {
  NSString *adUnitId = (NSString *)call.arguments[@"adUnitId"];
  if (adUnitId == nil || [adUnitId length] == 0) {
    NSString *message =
        [NSString stringWithFormat:@"a null or empty adUnitId was provided for %@", id];
    result([FlutterError errorWithCode:@"no_adunit_id" message:message details:nil]);
    return;
  }

  NSNumber *widthArg = (NSNumber *)call.arguments[@"width"];
  NSNumber *heightArg = (NSNumber *)call.arguments[@"height"];

  if (widthArg == nil || heightArg == nil) {
    NSString *message =
        [NSString stringWithFormat:@"a null height or width was provided for banner id=%@", id];
    result([FlutterError errorWithCode:@"invalid_adsize" message:message details:nil]);
    return;
  }

  NSString *adSizeTypeArg = (NSString *)call.arguments[@"adSizeType"];
  FLTLogWarning(@"Size Type: %@", adSizeTypeArg);
  if (adSizeTypeArg == nil || (![adSizeTypeArg isEqualToString:@"AdSizeType.SmartBanner"] &&
                               ![adSizeTypeArg isEqualToString:@"AdSizeType.WidthAndHeight"])) {
    NSString *message = [NSString
        stringWithFormat:@"a null or invalid ad size type was provided for banner id=%@", id];
    result([FlutterError errorWithCode:@"invalid_adsizetype" message:message details:nil]);
    return;
  }

  int width = [widthArg intValue];
  int height = [heightArg intValue];

  if ([adSizeTypeArg isEqualToString:@"AdSizeType.WidthAndHeight"] && (width <= 0 || height <= 0)) {
    NSString *message =
        [NSString stringWithFormat:@"an invalid AdSize (%d, %d) was provided for banner id=%@",
                                   width, height, id];
    result([FlutterError errorWithCode:@"invalid_adsize" message:message details:nil]);
    return;
  }

  GADAdSize adSize;
  if ([adSizeTypeArg isEqualToString:@"AdSizeType.SmartBanner"]) {
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
      adSize = kGADAdSizeSmartBannerPortrait;
    } else {
      adSize = kGADAdSizeSmartBannerLandscape;
    }
  } else {
    adSize = GADAdSizeFromCGSize(CGSizeMake(width, height));
  }

  FLTBannerAd *banner = [FLTBannerAd withId:id adSize:adSize channel:self.channel];

  if (banner.status != CREATED) {
    if (banner.status == FAILED) {
      NSString *message = [NSString stringWithFormat:@"cannot reload a failed ad=%@", banner];
      result([FlutterError errorWithCode:@"load_failed_ad" message:message details:nil]);
    } else {
      result([NSNumber numberWithBool:YES]);  // The ad was already loaded.
    }
  }

  NSDictionary *targetingInfo = (NSDictionary *)call.arguments[@"targetingInfo"];
  [banner loadWithAdUnitId:adUnitId targetingInfo:targetingInfo];
  result([NSNumber numberWithBool:YES]);
}

- (void)callLoadInterstitialAd:(FLTMobileAd *)ad
                          call:(FlutterMethodCall *)call
                        result:(FlutterResult)result {
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
        [NSString stringWithFormat:@"a null or emtpy adUnitId was provided for %@", ad];
    result([FlutterError errorWithCode:@"no_adunit_id" message:message details:nil]);
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

  double offset = 0.0;
  int type = 0;
  if (call.arguments[@"anchorOffset"] != nil) {
    offset = [call.arguments[@"anchorOffset"] doubleValue];
  }
  if (call.arguments[@"anchorType"] != nil) {
    type = [call.arguments[@"anchorType"] isEqualToString:@"bottom"] ? 0 : 1;
  }

  [ad showAtOffset:offset fromAnchor:type];
  result([NSNumber numberWithBool:YES]);
}

- (void)callIsAdLoaded:(NSNumber *)mobileAdId
                  call:(FlutterMethodCall *)call
                result:(FlutterResult)result {
  FLTMobileAd *ad = [FLTMobileAd getAdForId:mobileAdId];
  if (ad == nil) {
    NSString *message = [NSString
        stringWithFormat:@"isAdLoaded failed, no ad exists for id=%d", mobileAdId.intValue];
    result([FlutterError errorWithCode:@"no_ad_for_id" message:message details:nil]);
    return;
  }
  if (ad.status == LOADED) {
    result([NSNumber numberWithBool:YES]);
  } else {
    result([NSNumber numberWithBool:NO]);
  }
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
    NSString *message = @"FirebaseAdMobPlugin method calls for banners and "
                        @"interstitials must specify an "
                        @"integer mobile ad id";
    result([FlutterError errorWithCode:@"no_id" message:message details:nil]);
    return;
  }

  if ([call.method isEqualToString:@"loadBannerAd"]) {
    [self callLoadBannerAdWithId:mobileAdId channel:self.channel call:call result:result];
  } else if ([call.method isEqualToString:@"loadInterstitialAd"]) {
    [self callLoadInterstitialAd:[FLTInterstitialAd withId:mobileAdId channel:self.channel]
                            call:call
                          result:result];
  } else if ([call.method isEqualToString:@"showAd"]) {
    [self callShowAd:mobileAdId call:call result:result];
  } else if ([call.method isEqualToString:@"isAdLoaded"]) {
    [self callIsAdLoaded:mobileAdId call:call result:result];
  } else if ([call.method isEqualToString:@"disposeAd"]) {
    [self callDisposeAd:mobileAdId call:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
