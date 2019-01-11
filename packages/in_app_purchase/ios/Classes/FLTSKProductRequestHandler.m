//
//  FLTSKProductRequestWrapper.m
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import "FLTSKProductRequestHandler.h"
#import <StoreKit/StoreKit.h>

@interface FLTSKProductRequestHandler()<SKProductsRequestDelegate>

@property (strong, nonatomic) SKProductsRequest *request;

@end

@implementation FLTSKProductRequestHandler

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.request = [[SKProductsRequest alloc] init];
        self.request s
    }
    return self;
}

- (instancetype)initWithIdentifiers:(NSSet *)identifers
{
    self = [super init];
    if (self) {
        <#statements#>
    }
    return self;
}

@end
