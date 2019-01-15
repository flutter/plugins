//
//  FLTSKProductRequestWrapper.h
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ProductRequestCompletion)(SKProductsResponse *_Nullable response);

@interface FLTSKProductRequestHandler : NSObject

// method to get the complete SKProductResponse object
- (void)startWithProductIdentifiers:(NSSet<NSString *> *)identifers
                  completionHandler:(nullable ProductRequestCompletion)completion;

#pragma mark - methods for testing

- (nullable NSSet *)getDelegateObjects;

@end

@interface FLTSKProductRequestDelegateObject : NSObject

- (instancetype)initWithCompletionHandler:(nullable ProductRequestCompletion)completion;

#pragma mark - methods for testing

- (nullable NSSet *)getParentSet;

@end

NS_ASSUME_NONNULL_END

#pragma mark - categories

@interface SKProduct (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductSubscriptionPeriod (Coder)

- (nullable NSDictionary *)toMap;

@end

@interface SKProductDiscount (Coder)

- (nullable NSDictionary *)toMap;

@end
