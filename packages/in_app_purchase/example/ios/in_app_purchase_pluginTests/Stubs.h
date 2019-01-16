#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

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

NS_ASSUME_NONNULL_END
