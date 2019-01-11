//
//  FLTSKProductRequestWrapper.h
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface FLTSKProductRequestHandler : NSObject

@end

NS_ASSUME_NONNULL_END


#pragma mark - categories

@interface SKProduct(Coder)

- (NSDictionary *)toMap;

@end

@interface SKProductSubscriptionPeriod(Coder)

- (NSDictionary *)toMap;

@end

@interface SKProductDiscount(Coder)

- (NSDictionary *)toMap;

@end
