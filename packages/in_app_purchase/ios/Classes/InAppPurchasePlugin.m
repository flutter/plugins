// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>

@implementation InAppPurchasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase"
                                  binaryMessenger:[registrar messenger]];
  InAppPurchasePlugin* instance = [[InAppPurchasePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (!self) {
    return nil;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"-[SKPaymentQueue canMakePayments:]" isEqualToString:call.method]) {
    [self canMakePayments:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)canMakePayments:(FlutterResult)result {
  result([NSNumber numberWithBool:[SKPaymentQueue canMakePayments]]);
}

@end
