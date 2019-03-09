// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTRequestFactory.h"
#import "FirebaseAdMobPlugin.h"
#import "GoogleMobileAds/GADExtras.h"
#import "GoogleMobileAds/GoogleMobileAds.h"

@implementation FLTRequestFactory

NSDictionary *_targetingInfo;

- (instancetype)initWithTargetingInfo:(NSDictionary *)targetingInfo {
  self = [super init];
  if (self) {
    _targetingInfo = targetingInfo;
  }
  return self;
}

- (NSArray *)targetingInfoArrayForKey:(NSString *)key info:(NSDictionary *)info {
  NSObject *value = info[key];
  if (value == NULL) {
    return nil;
  }
  if (![value isKindOfClass:[NSArray class]]) {
    FLTLogWarning(@"targeting info %@: expected an array (MobileAd %@)", key, self);
    return nil;
  }
  return (NSArray *)value;
}

- (NSString *)targetingInfoStringForKey:(NSString *)key info:(NSDictionary *)info {
  NSObject *value = info[key];
  if (value == NULL) {
    return nil;
  }
  if (![value isKindOfClass:[NSString class]]) {
    FLTLogWarning(@"targeting info %@: expected a string (MobileAd %@)", key, self);
    return nil;
  }
  NSString *stringValue = (NSString *)value;
  if ([stringValue length] == 0) {
    FLTLogWarning(@"targeting info %@: expected a non-empty string (MobileAd %@)", key, self);
    return nil;
  }
  return stringValue;
}

- (NSNumber *)targetingInfoBoolForKey:(NSString *)key info:(NSDictionary *)info {
  NSObject *value = info[key];
  if (value == NULL) {
    return nil;
  }
  if (![value isKindOfClass:[NSNumber class]]) {
    FLTLogWarning(@"targeting info %@: expected a boolean, (MobileAd %@)", key, self);
    return nil;
  }
  return (NSNumber *)value;
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  if (_targetingInfo == nil) {
    return request;
  }

  NSArray *testDevices = [self targetingInfoArrayForKey:@"testDevices" info:_targetingInfo];
  if (testDevices != nil) {
    request.testDevices = testDevices;
  }

  NSArray *keywords = [self targetingInfoArrayForKey:@"keywords" info:_targetingInfo];
  if (keywords != nil) {
    request.keywords = keywords;
  }

  NSString *contentURL = [self targetingInfoStringForKey:@"contentUrl" info:_targetingInfo];
  if (contentURL != nil) {
    request.contentURL = contentURL;
  }

  NSObject *birthday = _targetingInfo[@"birthday"];
  if (birthday != NULL) {
    if (![birthday isKindOfClass:[NSNumber class]]) {
      FLTLogWarning(@"targeting info birthday: expected a long integer (MobileAd %@)", self);
    } else {
      // Incoming time value is milliseconds since the epoch, NSDate uses
      // seconds.
      request.birthday =
          [NSDate dateWithTimeIntervalSince1970:((NSNumber *)birthday).longValue / 1000.0];
    }
  }

  NSObject *gender = _targetingInfo[@"gender"];
  if (gender != NULL) {
    if (![gender isKindOfClass:[NSNumber class]]) {
      FLTLogWarning(@"targeting info gender: expected an integer (MobileAd %@)", self);
    } else {
      int genderValue = ((NSNumber *)gender).intValue;
      switch (genderValue) {
        case 0:  // MobileAdGender.unknown
        case 1:  // MobileAdGender.male
        case 2:  // MobileAdGender.female
          request.gender = genderValue;
          break;
        default:
          FLTLogWarning(@"targeting info gender: not one of 0, 1, or 2 (MobileAd %@)", self);
      }
    }
  }

  NSNumber *childDirected = [self targetingInfoBoolForKey:@"childDirected" info:_targetingInfo];
  if (childDirected != nil) {
    [request tagForChildDirectedTreatment:childDirected.boolValue];
  }

  NSString *requestAgent = [self targetingInfoStringForKey:@"requestAgent" info:_targetingInfo];
  if (requestAgent != nil) {
    request.requestAgent = requestAgent;
  }

  NSNumber *nonPersonalizedAds = [self targetingInfoBoolForKey:@"nonPersonalizedAds"
                                                          info:_targetingInfo];
  if (nonPersonalizedAds != nil && [nonPersonalizedAds boolValue]) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa" : @"1"};
    [request registerAdNetworkExtras:extras];
  }

  return request;
}

@end
