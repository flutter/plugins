#import "InAppPurchasePlugin.h"
#import <StoreKit/StoreKit.h>
#import "FLTSKProductRequestHandler.h"

@interface InAppPurchasePlugin ()

@property(strong, nonatomic) FLTSKProductRequestHandler *productRequestHandler;

@end

@implementation InAppPurchasePlugin

- (instancetype)init {
  self = [super init];
  if (self) {
    self.productRequestHandler = [FLTSKProductRequestHandler new];
  }
  return self;
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
  [self.productRequestHandler
      startWithProductIdentifiers:[NSSet setWithArray:productsIdentifiers]
                completionHandler:^(SKProductsResponse *_Nullable response) {
                  NSMutableArray *productsDetailsJSON = [NSMutableArray new];
                  for (SKProduct *product in response.products) {
                    [productsDetailsJSON addObject:[product toMap]];
                  }
                  result(productsDetailsJSON);
                }];
  [self.productRequestHandler
      startWithProductIdentifiers:[NSSet setWithArray:productsIdentifiers]
                completionHandler:^(SKProductsResponse *_Nullable response) {
                  NSMutableArray *productsDetailsJSON = [NSMutableArray new];
                  for (SKProduct *product in response.products) {
                    [productsDetailsJSON addObject:[product toMap]];
                  }
                  result(productsDetailsJSON);
                }];
}

@end
