// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "GoogleMobileAds/GoogleMobileAds.h"

@interface FLTRequestFactory : NSObject

- (instancetype)initWithTargetingInfo:(NSDictionary *)targetingInfo;
- (GADRequest *)createRequest;

@end
