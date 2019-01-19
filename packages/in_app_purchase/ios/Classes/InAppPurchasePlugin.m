// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAObjectTranslator.h"
#import "FIAPRequestHandler.h"

@interface InAppPurchasePlugin () <FIAPRequestHandlerDelegate>

@property(strong, nonatomic) NSMutableSet<FIAPRequestHandler *> *RequestHandlerSet;

@end

@implementation InAppPurchasePlugin

- (NSMutableSet<FIAPRequestHandler *> *)RequestHandlerSet {
  if (!_RequestHandlerSet) {
    _RequestHandlerSet = [NSMutableSet new];
  }
  return _RequestHandlerSet;
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
  } else if ([@"-[InAppPurchasePlugin startRequest:result:]" isEqualToString:call.method]) {
    [self startRequest:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)canMakePayments:(FlutterResult)result {
  result([NSNumber numberWithBool:[SKPaymentQueue canMakePayments]]);
}

- (void)startRequest:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.arguments isKindOfClass:[NSArray class]]) {
    result([FlutterError errorWithCode:@"storekit_invalide_argument"
                               message:@"Argument type of startRequest is not array"
                               details:call.arguments]);
    return;
  }
  NSArray *productsIdentifiers = (NSArray *)call.arguments;
  SKProductsRequest *request =
      [self getProductRequestWithIdentifiers:[NSSet setWithArray:productsIdentifiers]];
  FIAPRequestHandler *handler = [[FIAPRequestHandler alloc] initWithRequest:request];
  handler.delegate = self;
  [self.RequestHandlerSet addObject:handler];
  [handler startProductRequestWithCompletionHandler:^(SKProductsResponse *_Nullable response,
                                                      NSError *_Nullable error) {
    if (error) {
      NSString *details = [NSString stringWithFormat:@"Reason:%@\nRecoverSuggestion:%@",
                                                     error.localizedFailureReason,
                                                     error.localizedRecoverySuggestion];
      result([FlutterError errorWithCode:error.domain message:error.description details:details]);
      return;
    }
    if (!response) {
      result([FlutterError errorWithCode:@"storekit_platform_no_response"
                                 message:@"Failed to get SKProductResponse in startRequest "
                                         @"call. Error occured on IOS platform"
                                 details:call.arguments]);
      return;
    }
    result([response toMap]);
  }];
}

- (SKProductsRequest *)getProductRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
}

#pragma mark - delegates

- (void)requestHandlerDidFinish:(FIAPRequestHandler *)handler {
  if ([self.RequestHandlerSet containsObject:handler]) {
    [self.RequestHandlerSet removeObject:handler];
  }
}

@end
