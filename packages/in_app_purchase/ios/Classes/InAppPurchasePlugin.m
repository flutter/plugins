// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAObjectTranslator.h"
#import "FIAPRequestHandler.h"
#import "FIAPaymentQueueHandler.h"

typedef enum : NSUInteger {
    PaymentQueueCallbackTypeUpdate,
    PaymentQueueCallbackTypeRemoved,
    PaymentQueueCallbackTypeRestoreTransactionFailed,
    PaymentQueueCallbackTypeRestoreCompletedTransactionsFinished,
} PaymentQueueCallbackType;

@interface InAppPurchasePlugin ()

// Holding strong references to FIAPRequestHandlers. Remove the handlers from the set after
// the request is finished.
@property(strong, nonatomic) NSMutableSet *requestHandlers;

// After querying the product, the available products will be saved in the map to be used
// for purchase.
@property(copy, nonatomic) NSMutableDictionary *productsCache;
// Saved payment object used for resume payments;
@property(copy, nonatomic) NSMutableDictionary *paymentsCache;;

// Call back channel to dart used for when a listener function is triggered.
@property(strong, nonatomic) FlutterMethodChannel *callbackChannel;
@property(strong, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;

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
  } else if ([@"-[InAppPurchasePlugin createPaymentWithProductID:result:]" isEqualToString:call.method]) {
      [self createPaymentWithProductID:call result:result];
  } else if ([@"-[InAppPurchasePlugin addPayment:result:]" isEqualToString:call.method]) {
    [self addPayment:call result:result];
  } else if ([@"-[InAppPurchasePlugin finishTransaction:result:]" isEqualToString:call.method]) {
    [self finishTransaction:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    self = [self init];
    self.registrar = registrar;
    self.registry = [registrar textures];
    self.messenger = [registrar messenger];
    __weak typeof(self) weakSelf = self;
    self.paymentQueueHandler =
    [[FIAPaymentQueueHandler alloc] initWithQueue:[SKPaymentQueue defaultQueue]
                              transactionsUpdated:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
                                  [weakSelf handleTransactionsUpdated:transactions];
                              }
                               transactionRemoved:^(NSArray<SKPaymentTransaction *> *_Nonnull transactions) {
                                   [weakSelf handleTransactionsRemoved:transactions];
                               }
                         restoreTransactionFailed:^(NSError *_Nonnull error) {
                             [self handleTransactionRestoreFailed:error];
                         }
             restoreCompletedTransactionsFinished:^{
                 [self restoreCompletedTransactionsFinished];
             }
                            shouldAddStorePayment:^BOOL(SKPayment *payment, SKProduct *product) {
                                return [self shouldAddStorePayment:payment product:product];
                            }
                                 updatedDownloads:^void(NSArray<SKDownload *> *_Nonnull downloads) {
                                     [self updatedDownloads:downloads];
                                 }];
    self.callbackChannel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase_callback"
                                binaryMessenger:[registrar messenger]];
    return self;
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
  for (SKProduct *product in response.products) {
      [self.productsCache setObject:product forKey:product.productIdentifier];
  }
    result([FIAObjectTranslator getMapFromSKProductsResponse:response]);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

- (void)createPaymentWithProductID:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:@"storekit_invalide_argument"
                                   message:@"Argument type of createPaymentWithProductID is not a string."
                                   details:call.arguments]);
        return;
    }
    NSString *productID = call.arguments;
    SKProduct *product = [self.productsCache objectForKey:productID];
    if (!product) {
        result([FlutterError errorWithCode:@"storekit_product_not_found"
                                   message:@"Cannot find the product. To create a payment of a product, you must query the product with SKProductRequestMaker.startProductRequest."
                                   details:call.arguments]);
        return;
    }
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [self.paymentsCache setObject:payment forKey:productID];
    result([FIAObjectTranslator getMapFromSKPayment:payment]);
}

- (void)addPayment:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSDictionary class]]) {
        result([FlutterError errorWithCode:@"storekit_invalide_argument"
                                   message:@"Argument type of addPayment is not a map"
                                   details:call.arguments]);
        return;
    }
    NSDictionary *paymentMap = (NSDictionary *)call.arguments;
    NSString *productID = [paymentMap objectForKey:@"productID"];
    SKPayment *payment = [self.paymentsCache objectForKey:productID];
    // User can use  payment object with mutable = true and add simulatesAskToBuyInSandBox = true to test the payment flow.
    if (!payment || [paymentMap[@"mutable"] boolValue] == YES) {
        SKMutablePayment *mutablePayment = [[SKMutablePayment alloc] init];
        mutablePayment.productIdentifier = productID;
        NSNumber *quantity = [paymentMap objectForKey:@"quantity"];
        if (quantity) {
            mutablePayment.quantity = quantity.integerValue;
        }
        NSString *applicationUsername = [paymentMap objectForKey:@"applicationUsername"];
        mutablePayment.applicationUsername = applicationUsername;
        if (@available(iOS 8.3, *)) {
            mutablePayment.simulatesAskToBuyInSandbox =
            [[paymentMap objectForKey:@"simulatesAskToBuyInSandBox"] boolValue];
        }
        [self.paymentQueueHandler addPayment:payment];
    } else {
        [self.paymentQueueHandler addPayment:payment];
    }
}

- (void)finishTransaction:(FlutterMethodCall *)call result:(FlutterResult)result {
    if (![call.arguments isKindOfClass:[NSString class]]) {
        result([FlutterError errorWithCode:@"storekit_invalide_argument"
                                   message:@"Argument type of finishTransaction is not a string."
                                   details:call.arguments]);
        return;
    }
    NSString *identifier = call.arguments;
    SKPaymentTransaction *transaction = [self.paymentQueueHandler.transactions objectForKey:identifier];
    if (!transaction) {
        result([FlutterError errorWithCode:@"storekit_platform_invalid_transaction"
                                   message:@"Invalid transaction ID is used."
                                   details:call.arguments]);
        return;
    }
    @try {
        // finish transaction will throw exception if the transaction type is purchasing. Notify dart about this exception.
        [self.paymentQueueHandler finishTransaction:transaction];
    } @catch (NSException *e){
        result([FlutterError errorWithCode:@"storekit_finish_transaction_exception"
                                   message:e.name
                                   details:e.description]);
        return;
    }
}

#pragma mark - delegates

- (void)handleTransactionsUpdated:(NSArray<SKPaymentTransaction *> *)transactions {
    NSMutableArray *maps = [NSMutableArray new];
    for (SKPaymentTransaction *transcation in transactions) {
        [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transcation]];
    }
    [self.callbackChannel invokeMethod:@"updatedTransaction" arguments:maps];
}

- (void)handleTransactionsRemoved:(NSArray<SKPaymentTransaction *> *)transactions {
    NSMutableArray *maps = [NSMutableArray new];
    for (SKPaymentTransaction *transcation in transactions) {
        [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transcation]];
    }
    [self.callbackChannel invokeMethod:@"removedTransaction" arguments:maps];
}

- (void)handleTransactionRestoreFailed:(NSError *)error {
    FlutterError *fltError = [FlutterError errorWithCode:error.domain
                                                 message:error.description
                                                 details:error.description];
    [self.callbackChannel invokeMethod:@"restoreCompletedTransactions" arguments:fltError];
}

- (void)restoreCompletedTransactionsFinished {
    [self.callbackChannel invokeMethod:@"paymentQueueRestoreCompletedTransactionsFinished"
                             arguments:nil];
}

- (void)updatedDownloads:(NSArray<SKDownload *> *)downloads {
    NSMutableArray *maps = [NSMutableArray new];
    for (SKDownload *download in downloads) {
        [maps addObject:[FIAObjectTranslator getMapFromSKDownload:download]];
    }
    [self.callbackChannel invokeMethod:@"updatedDownloads" arguments:maps];
}

- (BOOL)shouldAddStorePayment:(SKPayment *)payment product:(SKProduct *)product {
    // We alwasy return NO here. And we send the message to dart to process the payment; and we will have a incerpection method that deciding if the payment should be processed (implemented by the programmer).
    [self.productsCache setObject:product forKey:product.productIdentifier];
    [self.paymentsCache setObject:payment forKey:payment.productIdentifier];
    [self.callbackChannel invokeMethod:@"shouldAddStorePayment" arguments:@{@"payment":[FIAObjectTranslator getMapFromSKPayment:payment],
                                                                            @"proudt":[FIAObjectTranslator getMapFromSKProduct:product]
                                                                            }];
    return NO;
}

#pragma mark - dependency injection (for unit testing)

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

- (NSMutableDictionary *)productsCache {
    if (!_productsCache) {
        _productsCache = [NSMutableDictionary new];
    }
    return _productsCache;
}

- (NSMutableDictionary *)paymentsCache {
    if (!_paymentsCache) {
        _paymentsCache = [NSMutableDictionary new];
    }
    return _paymentsCache;
}

@end
