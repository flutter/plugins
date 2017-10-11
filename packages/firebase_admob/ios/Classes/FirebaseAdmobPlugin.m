// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "FirebaseAdmobPlugin.h"
#import "Firebase/Firebase.h"
#import "MobileAd.h"

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

@interface FirebaseAdMobPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseAdMobPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FirebaseAdMobPlugin *instance = [[FirebaseAdMobPlugin alloc] init];
  instance.channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_admob"
                                  binaryMessenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (instancetype)init {
  self = [super init];
  if (self && ![FIRApp defaultApp]) {
    NSLog(@"[FIRApp configure]");
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
  [MobileAd configureWithAppId:appId];
  result([NSNumber numberWithBool:YES]);
}

- (void)callLoadAd:(MobileAd *)ad call:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (ad.status != CREATED) {
    if (ad.status == FAILED) {
      NSString *message = [NSString stringWithFormat:@"cannot reload a failed ad=%@", ad];
      result([FlutterError errorWithCode:@"load_failed_ad" message:message details:nil]);
    } else {
      result([NSNumber numberWithBool:YES]);  // The ad was already loaded.
    }
  }

  NSString *unitId = (NSString *)call.arguments[@"unitId"];
  if (unitId == nil || [unitId length] == 0) {
    NSString *message =
        [NSString stringWithFormat:@"a non-empty unitId was not provided for %@", ad];
    result([FlutterError errorWithCode:@"no_unit_id" message:message details:nil]);
    return;
  }

  NSDictionary *targetingInfo = (NSDictionary *)call.arguments[@"targetingInfo"];
  [ad loadWithUnitId:unitId targetingInfo:targetingInfo];
  result([NSNumber numberWithBool:YES]);
}

- (void)callShowAd:(NSNumber *)mobileAdId
              call:(FlutterMethodCall *)call
            result:(FlutterResult)result {
  MobileAd *ad = [MobileAd getAdForId:mobileAdId];
  if (ad == nil) {
    NSString *message =
        [NSString stringWithFormat:@"show failed, the specified ad was not loaded id=%d",
                                   mobileAdId.intValue];
    result([FlutterError errorWithCode:@"ad_not_loaded" message:message details:nil]);
  }

  [ad show];
  result([NSNumber numberWithBool:YES]);
}

- (void)callDisposeAd:(NSNumber *)mobileAdId
                 call:(FlutterMethodCall *)call
               result:(FlutterResult)result {
  MobileAd *ad = [MobileAd getAdForId:mobileAdId];
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

  NSNumber *mobileAdId = (NSNumber *)call.arguments[@"id"];
  if (mobileAdId == nil) {
    NSString *message =
        @"all FirebaseAdMobPlugin method calls must specify an "
        @"integer mobile ad id";
    result([FlutterError errorWithCode:@"no_id" message:message details:nil]);
    return;
  }

  if ([call.method isEqualToString:@"loadBannerAd"]) {
    [self callLoadAd:[BannerAd withId:mobileAdId channel:self.channel] call:call result:result];
  } else if ([call.method isEqualToString:@"loadInterstitialAd"]) {
    [self callLoadAd:[InterstitialAd withId:mobileAdId channel:self.channel]
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
