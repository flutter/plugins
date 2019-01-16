#import "Stubs.h"

@implementation SKProductSubscriptionPeriodStub

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setValue:@(0) forKey:@"numberOfUnits"];
        [self setValue:@(0) forKey:@"unit"];
    }
    return self;
}

@end

@implementation SKProductDiscountStub

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setValue:@(1.0) forKey:@"price"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [self setValue:locale forKey:@"priceLocale"];
        [self setValue:@(1) forKey:@"numberOfPeriods"];
        SKProductSubscriptionPeriodStub *subscriptionPeriodSub =
        [[SKProductSubscriptionPeriodStub alloc] init];
        [self setValue:subscriptionPeriodSub forKey:@"subscriptionPeriod"];
        [self setValue:@(1) forKey:@"paymentMode"];
    }
    return self;
}

@end

@implementation SKProductStub

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setValue:@"consumable" forKey:@"productIdentifier"];
        [self setValue:@"description" forKey:@"localizedDescription"];
        [self setValue:@"title" forKey:@"localizedTitle"];
        [self setValue:@YES forKey:@"downloadable"];
        [self setValue:@(1.0) forKey:@"price"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [self setValue:locale forKey:@"priceLocale"];
        [self setValue:@[ @1, @2 ] forKey:@"downloadContentLengths"];
        SKProductSubscriptionPeriodStub *period = [[SKProductSubscriptionPeriodStub alloc] init];
        [self setValue:period forKey:@"subscriptionPeriod"];
        SKProductDiscountStub *discount = [[SKProductDiscountStub alloc] init];
        [self setValue:discount forKey:@"introductoryPrice"];
        [self setValue:@"com.group" forKey:@"subscriptionGroupIdentifier"];
    }
    return self;
}

@end

@implementation SKProductRequestStub

@end
