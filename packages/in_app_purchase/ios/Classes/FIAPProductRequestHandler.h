#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response);

@interface FIAPProductRequestHandler : NSObject

- (instancetype)initWithRequestRequest:(SKProductsRequest *)request;
- (void)startWithCompletionHandler:(ProductRequestCompletion)completion;

NS_ASSUME_NONNULL_END

#pragma mark - categories

@end

@interface SKProduct (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductSubscriptionPeriod (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductDiscount (Coder)

- (nullable NSDictionary *)toMap;

@end
