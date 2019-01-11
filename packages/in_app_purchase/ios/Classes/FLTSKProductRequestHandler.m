//
//  FLTSKProductRequestWrapper.m
//  in_app_purchase
//
//  Created by Chris Yang on 1/10/19.
//

#import "FLTSKProductRequestHandler.h"
#import <StoreKit/StoreKit.h>

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
    [self.request start];
    self.completion = completion;
}


#pragma mark SKProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    if (self.completion) {
        self.completion(response);
    }
}

@end
