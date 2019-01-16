#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "FIAPProductRequestHandler.h"
#import "InAppPurchasePlugin.h"

NS_ASSUME_NONNULL_BEGIN
@interface SKProductSubscriptionPeriodStub : SKProductSubscriptionPeriod
@end

@interface SKProductDiscountStub : SKProductDiscount
@end

@interface SKProductStub : SKProduct
- (nonnull instancetype)initWithIdentifier:(nullable NSString *)identifier;
@end

@interface SKProductRequestStub : SKProductsRequest
@end

@interface SKProductsResponseStub : SKProductsResponse
- (instancetype)initWithIdentifiers:(NSSet *)identifiers;
@end

@interface InAppPurchasePluginStub : InAppPurchasePlugin
@end
NS_ASSUME_NONNULL_END
