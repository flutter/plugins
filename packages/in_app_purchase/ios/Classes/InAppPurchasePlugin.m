// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAObjectTranslator.h"
#import "FIAPRequestHandler.h"

@interface InAppPurchasePlugin ()

// Holding strong references to FIAPRequestHandlers. Remove the handlers from the set after
// the request is finished.
@property(strong, nonatomic) NSMutableSet *requestHandlers;

@end

@implementation InAppPurchasePlugin

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
  } else if ([@"-[InAppPurchasePlugin startProductRequest:result:]" isEqualToString:call.method]) {
    [self handleProductRequestMethodCall:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)canMakePayments:(FlutterResult)result {
  result([NSNumber numberWithBool:[SKPaymentQueue canMakePayments]]);
}

- (void)handleProductRequestMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.arguments isKindOfClass:[NSArray class]]) {
    result([FlutterError errorWithCode:@"storekit_invalid_argument"
                               message:@"Argument type of startRequest is not array"
                               details:call.arguments]);
    return;
  }
  NSArray *productIdentifiers = (NSArray *)call.arguments;
  SKProductsRequest *request =
      [self getProductRequestWithIdentifiers:[NSSet setWithArray:productIdentifiers]];
  FIAPRequestHandler *handler = [[FIAPRequestHandler alloc] initWithRequest:request];
  [self.requestHandlers addObject:handler];
  __weak typeof(self) weakSelf = self;
  [handler startProductRequestWithCompletionHandler:^(SKProductsResponse *_Nullable response,
                                                      NSError *_Nullable error) {
    if (error) {
      NSString *details = [NSString stringWithFormat:@"Reason:%@\nRecoverSuggestion:%@",
                                                     error.localizedFailureReason,
                                                     error.localizedRecoverySuggestion];
      result([FlutterError errorWithCode:@"storekit_getproductrequest_platform_error"
                                 message:error.description
                                 details:details]);
      return;
    }
    if (!response) {
      result([FlutterError errorWithCode:@"storekit_platform_no_response"
                                 message:@"Failed to get SKProductResponse in startRequest "
                                         @"call. Error occured on iOS platform"
                                 details:call.arguments]);
      return;
    }
    result([FIAObjectTranslator getMapFromSKProductsResponse:response]);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

- (SKProductsRequest *)getProductRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
}

#pragma mark - getter

- (NSSet *)requestHandlers {
  if (!_requestHandlers) {
    _requestHandlers = [NSMutableSet new];
  }
  return _requestHandlers;
}

@end
