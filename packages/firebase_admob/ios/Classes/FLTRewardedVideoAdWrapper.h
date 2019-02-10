// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import "GoogleMobileAds/GoogleMobileAds.h"

typedef enum : NSUInteger {
  FLTRewardedVideoAdStatusCreated,
  FLTRewardedVideoAdStatusLoading,
  FLTRewardedVideoAdStatusFailed,
  FLTRewardedVideoAdStatusLoaded,
} FLTRewardedVideoAdStatus;

@interface FLTRewardedVideoAdWrapper : NSObject
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel;
- (FLTRewardedVideoAdStatus)status;
- (void)loadWithAdUnitId:(NSString *)adUnitId targetingInfo:(NSDictionary *)targetingInfo;
- (void)show;
@end
