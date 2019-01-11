//
//  FLTSKProductRequestWrapper.m
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import "FLTSKProductRequestHandler.h"
#import <StoreKit/StoreKit.h>

#pragma mark - Main Handler

typedef void(^ProductRequestCompletion)(SKProductsResponse * _Nullable response);

@interface FLTSKProductRequestHandler()<SKProductsRequestDelegate>

@property (strong, nonatomic) SKProductsRequest *request;
@property (copy, nonatomic) ProductRequestCompletion completion;

@end

@implementation FLTSKProductRequestHandler

- (instancetype)initWithProductIdentifiers:(NSSet<NSString *> *)identifers
{
    self = [super init];
    if (self) {
        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifers];
        self.request.delegate = self;
    }
    return self;
}

// method to get the complete SKProductResponse object
- (void)startWithCompletionHandler:(nullable ProductRequestCompletion)completion {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        self.completion = completion;
        [self.request start];
    });
}


#pragma mark SKProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.completion) {
            self.completion(response);
        }
    });
}

@end

#pragma mark - SKProduct Coders

@implementation SKProduct(Coder)

- (NSDictionary *)toMap {
    NSMutableDictionary *map = [[NSMutableDictionary
                                 alloc]
                                initWithDictionary:@{
                                                     @"localizedDescription": self.localizedDescription,
                                                     @"localizedTitle": self.localizedTitle,
                                                     @"price": self.price,
                                                     @"priceLocale": self.priceLocale,
                                                     @"productIdentifier": self.productIdentifier,
                                                     @"downloadable": @(self.downloadable),
                                                     @"downloadContentLengths": self.downloadContentLengths,
                                                     @"downloadContentVersion": self.downloadContentVersion,
                                }];
    if (@available(iOS 11.2, *)) {
        if (self.subscriptionPeriod) {
            [map setObject:[self.subscriptionPeriod toMap] forKey:@"subscriptionPeriod"];
        }
    }
    if (@available(iOS 11.2, *)) {
        if (self.introductoryPrice) {
            [map setObject:[self.introductoryPrice toMap] forKey:@"introductoryPrice"];
        }
    }
    if (@available(iOS 12.0, *)) {
        if (self.subscriptionGroupIdentifier) {
            [map setObject:self.subscriptionGroupIdentifier forKey:@"subscriptionGroupIdentifier"];
        }
    }
    return map;
}


@end


@implementation SKProductSubscriptionPeriod(Coder)

- (NSDictionary *)toMap {
    return @{
             @"numberOfUnits":@(self.numberOfUnits),
             @"unit":@(self.unit)
             };
}

@end

@implementation SKProductDiscount(Coder)

- (NSDictionary *)toMap {
    return @{
             @"price": self.price,
             @"priceLocale": self.priceLocale,
             @"numberOfPeriods": @(self.numberOfPeriods),
             @"subscriptionPeriod": [self.subscriptionPeriod toMap],
             @"paymentMode": @(self.paymentMode)
             };
}

@end
