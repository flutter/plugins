// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTCookieManager : NSObject <FlutterPlugin>

+ (FLTCookieManager*)instance;

- (void)setCookiesForData:(NSArray<NSDictionary*>*)cookies;

- (void)setCookieForData:(NSDictionary*)cookie;

@end

NS_ASSUME_NONNULL_END
