// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAPProductRequestHandler.h"

@interface InAppPurchasePlugin () <FIAPProductRequestHandlerDelegate>

@property(strong, nonatomic) NSMutableSet<FIAPProductRequestHandler *> *productRequestHandlerSet;

@end

@implementation InAppPurchasePlugin

- (NSMutableSet<FIAPProductRequestHandler *> *)productRequestHandlerSet {
  if (!_productRequestHandlerSet) {
    _productRequestHandlerSet = [NSMutableSet new];
  }
  return _productRequestHandlerSet;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase"
                                  binaryMessenger:[registrar messenger]];
  InAppPurchasePlugin *instance = [[InAppPurchasePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"-[SKPaymentQueue canMakePayments:]" isEqualToString:call.method]) {
    [self canMakePayments:result];
  } else if ([@"startProductRequest" isEqualToString:call.method]) {
    [self startProductRequest:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)canMakePayments:(FlutterResult)result {
  result([NSNumber numberWithBool:[SKPaymentQueue canMakePayments]]);
}

- (void)startProductRequest:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.arguments isKindOfClass:[NSArray class]]) {
    result([FlutterError errorWithCode:@"storekit_invalide_argument"
                               message:@"Argument type of startProductRequest is not array"
                               details:call.arguments]);
  }
  NSArray *productsIdentifiers = (NSArray *)call.arguments;
  SKProductsRequest *request =
      [self getRequestWithIdentifiers:[NSSet setWithArray:productsIdentifiers]];
  FIAPProductRequestHandler *handler =
      [[FIAPProductRequestHandler alloc] initWithRequestRequest:request];
  handler.delegate = self;
  [self.productRequestHandlerSet addObject:handler];
  [handler startWithCompletionHandler:^(SKProductsResponse *_Nullable response) {
    if (!response) {
      result([FlutterError errorWithCode:@"storekit_platform_no_response"
                                 message:@"Failed to get SKProductResponse in startProductRequest "
                                         @"call. Error occured on IOS platform"
                                 details:call.arguments]);
      return;
    }
    result([response toMap]);
  }];
}

- (SKProductsRequest *)getRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
}

#pragma mark - delegates

- (void)productRequestHandlerDidFinish:(FIAPProductRequestHandler *)handler {
  if ([self.productRequestHandlerSet containsObject:handler]) {
    [self.productRequestHandlerSet removeObject:handler];
  }
}

@end
