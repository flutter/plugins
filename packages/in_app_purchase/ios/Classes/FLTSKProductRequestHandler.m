//
//  FLTSKProductRequestWrapper.m
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import "FLTSKProductRequestHandler.h"
#import <StoreKit/StoreKit.h>

#pragma mark - Main Handler

@interface FLTSKProductRequestHandler()<SKProductsRequestDelegate>

@property (copy, nonatomic) ProductRequestCompletion completion;
@property (strong, nonatomic) SKProductsRequest *request;

@end

@implementation FLTSKProductRequestHandler

// method to get the complete SKProductResponse object
- (void)startWithProductIdentifiers:(NSSet<NSString *> *)identifers completionHandler:(nullable ProductRequestCompletion)completion {
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifers];
    self.request.delegate = self;
    self.completion = completion;
    [self.request start];

}


#pragma mark SKProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (self.completion) {
        self.completion(response);
    }
}

@end

#pragma mark - SKProduct Coders

@implementation SKProduct(Coder)

- (NSDictionary *)toMap {
    NSMutableDictionary *map = [[NSMutableDictionary
                                 alloc]
                                initWithDictionary:@{
                                                     @"localizedDescription": self.localizedDescription?:@"",
                                                     @"localizedTitle": self.localizedTitle?:@"",
                                                     @"productIdentifier": self.productIdentifier,
                                                     @"downloadable": @(self.downloadable)
                                }];
    if (self.price) {
        [map setObject:self.price forKey:@"price"];
    }
    if (@available(iOS 10.0, *)) {
        if (self.priceLocale.currencyCode) {
            // TODO: NSLocle is a complex object, want to see the actual need of getting this expanded to a map.
            // Matching android to only get the currencyCode for now.
            [map setObject:self.priceLocale.currencyCode forKey:@"currencyCode"];
        }
    }
    if (self.downloadContentLengths) {
        [map setObject:self.downloadContentLengths forKey:@"downloadContentLengths"];
    }
    if (self.downloadContentVersion) {
        [map setObject:self.downloadContentVersion forKey:@"downloadContentVersion"];
    }
    if (@available(iOS 11.2, *)) {
        if (self.subscriptionPeriod) {
            [map setObject:[self.subscriptionPeriod toMap]?:@{} forKey:@"subscriptionPeriod"];
        }
    }
    if (@available(iOS 11.2, *)) {
        if (self.introductoryPrice) {
            [map setObject:[self.introductoryPrice toMap]?:@{} forKey:@"introductoryPrice"];
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
