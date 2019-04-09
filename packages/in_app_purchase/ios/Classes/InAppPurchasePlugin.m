// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FIAObjectTranslator.h"
#import "FIAPReceiptManager.h"
#import "FIAPRequestHandler.h"
#import "FIAPaymentQueueHandler.h"

@interface InAppPurchasePlugin ()

// Holding strong references to FIAPRequestHandlers. Remove the handlers from the set after
// the request is finished.
@property(strong, nonatomic) NSMutableSet *requestHandlers;

// After querying the product, the available products will be saved in the map to be used
// for purchase.
@property(copy, nonatomic) NSMutableDictionary *productsCache;

// Call back channel to dart used for when a listener function is triggered.
@property(strong, nonatomic) FlutterMethodChannel *callbackChannel;
@property(strong, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(strong, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(strong, nonatomic) NSObject<FlutterPluginRegistrar> *registrar;

@property(strong, nonatomic) FIAPReceiptManager *receiptManager;

@end

@implementation InAppPurchasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase"
                                  binaryMessenger:[registrar messenger]];
  InAppPurchasePlugin *instance = [[InAppPurchasePlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithReceiptManager:(FIAPReceiptManager *)receiptManager {
  self = [self init];
  self.receiptManager = receiptManager;
  return self;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  self = [self initWithReceiptManager:[FIAPReceiptManager new]];
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
            [weakSelf handleTransactionRestoreFailed:error];
          }
          restoreCompletedTransactionsFinished:^{
            [weakSelf restoreCompletedTransactionsFinished];
          }
          shouldAddStorePayment:^BOOL(SKPayment *payment, SKProduct *product) {
            return [weakSelf shouldAddStorePayment:payment product:product];
          }
          updatedDownloads:^void(NSArray<SKDownload *> *_Nonnull downloads) {
            [weakSelf updatedDownloads:downloads];
          }];
  self.callbackChannel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/in_app_purchase_callback"
                                  binaryMessenger:[registrar messenger]];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"-[SKPaymentQueue canMakePayments:]" isEqualToString:call.method]) {
    [self canMakePayments:result];
  } else if ([@"-[InAppPurchasePlugin startProductRequest:result:]" isEqualToString:call.method]) {
    [self handleProductRequestMethodCall:call result:result];
  } else if ([@"-[InAppPurchasePlugin addPayment:result:]" isEqualToString:call.method]) {
    [self addPayment:call result:result];
  } else if ([@"-[InAppPurchasePlugin finishTransaction:result:]" isEqualToString:call.method]) {
    [self finishTransaction:call result:result];
  } else if ([@"-[InAppPurchasePlugin restoreTransactions:result:]" isEqualToString:call.method]) {
    [self restoreTransactions:call result:result];
  } else if ([@"-[InAppPurchasePlugin retrieveReceiptData:result:]" isEqualToString:call.method]) {
    [self retrieveReceiptData:call result:result];
  } else if ([@"-[InAppPurchasePlugin refreshReceipt:result:]" isEqualToString:call.method]) {
    [self refreshReceipt:call result:result];
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
    for (SKProduct *product in response.products) {
      [self.productsCache setObject:product forKey:product.productIdentifier];
    }
    result([FIAObjectTranslator getMapFromSKProductsResponse:response]);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

- (void)addPayment:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.arguments isKindOfClass:[NSDictionary class]]) {
    result([FlutterError errorWithCode:@"storekit_invalid_argument"
                               message:@"Argument type of addPayment is not a Dictionary"
                               details:call.arguments]);
    return;
  }
  NSDictionary *paymentMap = (NSDictionary *)call.arguments;
  NSString *productID = [paymentMap objectForKey:@"productIdentifier"];
  // When a product is already fetched, we create a payment object with
  // the product to process the payment.
  SKProduct *product = [self getProduct:productID];
  if (product) {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.applicationUsername = [paymentMap objectForKey:@"applicationUsername"];
    NSNumber *quantity = [paymentMap objectForKey:@"quantity"];
    payment.quantity = quantity ? quantity.integerValue : 1;
    if (@available(iOS 8.3, *)) {
      payment.simulatesAskToBuyInSandbox =
          [[paymentMap objectForKey:@"simulatesAskToBuyInSandBox"] boolValue];
    }
    [self.paymentQueueHandler addPayment:payment];
    result(nil);
    return;
  }
  result([FlutterError
      errorWithCode:@"storekit_invalid_payment_object"
            message:@"You have requested a payment for an invalid product. Either the "
                    @"`productIdentifier` of the payment is not valid or the product has not been "
                    @"fetched before adding the payment to the payment queue."
            details:call.arguments]);
}

- (void)finishTransaction:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (![call.arguments isKindOfClass:[NSString class]]) {
    result([FlutterError errorWithCode:@"storekit_invalid_argument"
                               message:@"Argument type of finishTransaction is not a string."
                               details:call.arguments]);
    return;
  }
  NSString *identifier = call.arguments;
  SKPaymentTransaction *transaction =
      [self.paymentQueueHandler.transactions objectForKey:identifier];
  if (!transaction) {
    result([FlutterError
        errorWithCode:@"storekit_platform_invalid_transaction"
              message:[NSString
                          stringWithFormat:@"The transaction with transactionIdentifer:%@ does not "
                                           @"exist. Note that if the transactionState is "
                                           @"purchasing, the transactionIdentifier will be "
                                           @"nil(null).",
                                           transaction.transactionIdentifier]
              details:call.arguments]);
    return;
  }
  @try {
    // finish transaction will throw exception if the transaction type is purchasing. Notify dart
    // about this exception.
    [self.paymentQueueHandler finishTransaction:transaction];
  } @catch (NSException *e) {
    result([FlutterError errorWithCode:@"storekit_finish_transaction_exception"
                               message:e.name
                               details:e.description]);
    return;
  }
  result(nil);
}

- (void)restoreTransactions:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (call.arguments && ![call.arguments isKindOfClass:[NSString class]]) {
    result([FlutterError
        errorWithCode:@"storekit_invalid_argument"
              message:@"Argument is not nil and the type of finishTransaction is not a string."
              details:call.arguments]);
    return;
  }
  [self.paymentQueueHandler restoreTransactions:call.arguments];
}

- (void)retrieveReceiptData:(FlutterMethodCall *)call result:(FlutterResult)result {
  FlutterError *error = nil;
  NSString *receiptData = [self.receiptManager retrieveReceiptWithError:&error];
  if (error) {
    result(error);
    return;
  }
  result(receiptData);
}

- (void)refreshReceipt:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;
  SKReceiptRefreshRequest *request;
  if (arguments) {
    if (![arguments isKindOfClass:[NSDictionary class]]) {
      result([FlutterError errorWithCode:@"storekit_invalid_argument"
                                 message:@"Argument type of startRequest is not array"
                                 details:call.arguments]);
      return;
    }
    NSMutableDictionary *properties = [NSMutableDictionary new];
    properties[SKReceiptPropertyIsExpired] = arguments[@"isExpired"];
    properties[SKReceiptPropertyIsRevoked] = arguments[@"isRevoked"];
    properties[SKReceiptPropertyIsVolumePurchase] = arguments[@"isVolumePurchase"];
    request = [self getRefreshReceiptRequest:properties];
  } else {
    request = [self getRefreshReceiptRequest:nil];
  }
  FIAPRequestHandler *handler = [[FIAPRequestHandler alloc] initWithRequest:request];
  [self.requestHandlers addObject:handler];
  __weak typeof(self) weakSelf = self;
  [handler startProductRequestWithCompletionHandler:^(SKProductsResponse *_Nullable response,
                                                      NSError *_Nullable error) {
    if (error) {
      result([FlutterError errorWithCode:@"storekit_refreshreceiptrequest_platform_error"
                                 message:error.description
                                 details:error.userInfo]);
      return;
    }
    result(nil);
    [weakSelf.requestHandlers removeObject:handler];
  }];
}

#pragma mark - delegates

- (void)handleTransactionsUpdated:(NSArray<SKPaymentTransaction *> *)transactions {
  NSMutableArray *maps = [NSMutableArray new];
  for (SKPaymentTransaction *transaction in transactions) {
    [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]];
  }
  [self.callbackChannel invokeMethod:@"updatedTransactions" arguments:maps];
}

- (void)handleTransactionsRemoved:(NSArray<SKPaymentTransaction *> *)transactions {
  NSMutableArray *maps = [NSMutableArray new];
  for (SKPaymentTransaction *transaction in transactions) {
    [maps addObject:[FIAObjectTranslator getMapFromSKPaymentTransaction:transaction]];
  }
  [self.callbackChannel invokeMethod:@"removedTransactions" arguments:maps];
}

- (void)handleTransactionRestoreFailed:(NSError *)error {
  [self.callbackChannel invokeMethod:@"restoreCompletedTransactionsFailed"
                           arguments:[FIAObjectTranslator getMapFromNSError:error]];
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
  // We always return NO here. And we send the message to dart to process the payment; and we will
  // have a interception method that deciding if the payment should be processed (implemented by the
  // programmer).
  [self.productsCache setObject:product forKey:product.productIdentifier];
  [self.callbackChannel invokeMethod:@"shouldAddStorePayment"
                           arguments:@{
                             @"payment" : [FIAObjectTranslator getMapFromSKPayment:payment],
                             @"product" : [FIAObjectTranslator getMapFromSKProduct:product]
                           }];
  return NO;
}

#pragma mark - dependency injection (for unit testing)

- (SKProductsRequest *)getProductRequestWithIdentifiers:(NSSet *)identifiers {
  return [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
}

- (SKProduct *)getProduct:(NSString *)productID {
  return [self.productsCache objectForKey:productID];
}

- (SKReceiptRefreshRequest *)getRefreshReceiptRequest:(NSDictionary *)properties {
  return [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:properties];
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

@end
