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
  } else if ([@"getProductList" isEqualToString:call.method]) {
    [self getProductListWithMethodCall:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)canMakePayments:(FlutterResult)result {
  result([NSNumber numberWithBool:[SKPaymentQueue canMakePayments]]);
}

- (void)getProductListWithMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSArray *productsIdentifiers = call.arguments[@"identifiers"];
  SKProductsRequest *request =
      [self getRequestWithIdentifiers:[NSSet setWithArray:productsIdentifiers]];
  FIAPProductRequestHandler *handler =
      [[FIAPProductRequestHandler alloc] initWithRequestRequest:request];
  handler.delegate = self;
  NSMutableArray *productDetailsSerialized = [NSMutableArray new];
  [self.productRequestHandlerSet addObject:handler];
  [handler startWithCompletionHandler:^(SKProductsResponse *_Nullable response) {
    for (SKProduct *product in response.products) {
      [productDetailsSerialized addObject:[product toMap]];
    }
    result(productDetailsSerialized);
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
