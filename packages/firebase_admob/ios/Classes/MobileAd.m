// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#import "MobileAd.h"
#import "FirebaseAdmobPlugin.h"

static NSMutableDictionary *allAds = nil;
static NSDictionary *statusToString = nil;

static void logWarning(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  NSLog(@"FirebaseAdMobPlugin <Warning> %@", message);
}

@implementation MobileAd
NSNumber *_mobileAdId;
FlutterMethodChannel *_channel;
MobileAdStatus _status;

+ (void)initialize {
  if (allAds == nil) {
    allAds = [[NSMutableDictionary alloc] init];
  }

  if (statusToString == nil) {
    statusToString = @{
      @(CREATED) : @"CREATED",
      @(LOADING) : @"LOADING",
      @(FAILED) : @"FAILED",
      @(PENDING) : @"PENDING",
      @(LOADED) : @"LOADED"
    };
  }
}

+ (void)configureWithAppId:(NSString *)appId {
  [GADMobileAds configureWithApplicationID:appId];
}

+ (MobileAd *)getAdForId:(NSNumber *)mobileAdId {
  return allAds[mobileAdId];
}

+ (UIViewController *)rootViewController {
  return [UIApplication sharedApplication].delegate.window.rootViewController;
}

- (instancetype)initWithId:(NSNumber *)mobileAdId channel:(FlutterMethodChannel *)channel {
  self = [super init];
  if (self) {
    _mobileAdId = mobileAdId;
    _channel = channel;
    _status = CREATED;
    allAds[mobileAdId] = self;
  }
  return self;
}

- (MobileAdStatus)status {
  return _status;
}

- (void)loadWithUnitId:(NSString *)unitId targetingInfo:(NSDictionary *)targetingInfo {
  // Implemented by the Banner and Interstitial subclasses
}

- (void)show {
  // Implemented by the Banner and Interstitial subclasses
}

- (void)dispose {
  [allAds removeObjectForKey:_mobileAdId];
}

- (NSArray *)targetingInfoArrayForKey:(NSString *)key info:(NSDictionary *)info {
  NSObject *value = info[key];
  if (value == NULL) {
    return nil;
  }
  if (![value isKindOfClass:[NSArray class]]) {
    logWarning(@"targeting info %@: expected an array (MobileAd %@)", key, self);
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
    logWarning(@"targeting info %@: expected a string (MobileAd %@)", key, self);
    return nil;
  }
  NSString *stringValue = (NSString *)value;
  if ([stringValue length] == 0) {
    logWarning(@"targeting info %@: expected a non-empty string (MobileAd %@)", key, self);
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
    logWarning(@"targeting info %@: expected a boolean, (MobileAd %@)", key, self);
    return nil;
  }
  return (NSNumber *)value;
}

- (GADRequest *)createLoadRequest:(NSDictionary *)targetingInfo {
  GADRequest *request = [GADRequest request];
  if (targetingInfo == nil) {
    return request;
  }

  NSArray *testDevices = [self targetingInfoArrayForKey:@"testDevices" info:targetingInfo];
  if (testDevices != nil) {
    request.testDevices = testDevices;
  }

  NSArray *keywords = [self targetingInfoArrayForKey:@"keywords" info:targetingInfo];
  if (keywords != nil) {
    request.keywords = keywords;
  }

  NSString *contentURL = [self targetingInfoStringForKey:@"contentUrl" info:targetingInfo];
  if (contentURL != nil) {
    request.contentURL = contentURL;
  }

  NSObject *birthday = targetingInfo[@"birthday"];
  if (birthday != NULL) {
    if (![birthday isKindOfClass:[NSNumber class]]) {
      logWarning(@"targeting info birthday: expected a long integer (MobileAd %@)", self);
    } else {
      // Incoming time value is milliseconds since the epoch, NSDate uses
      // seconds.
      request.birthday =
          [NSDate dateWithTimeIntervalSince1970:((NSNumber *)birthday).longValue / 1000.0];
    }
  }

  NSObject *gender = targetingInfo[@"gender"];
  if (gender != NULL) {
    if (![gender isKindOfClass:[NSNumber class]]) {
      logWarning(@"targeting info gender: expected an integer (MobileAd %@)", self);
    } else {
      int genderValue = ((NSNumber *)gender).intValue;
      switch (genderValue) {
        case 0:  // MobileAdGender.unknown
        case 1:  // MobileAdGender.male
        case 2:  // MobileAdGender.female
          request.gender = genderValue;
          break;
        default:
          logWarning(@"targeting info gender: not one of 0, 1, or 2 (MobileAd %@)", self);
      }
    }
  }

  NSNumber *childDirected = [self targetingInfoBoolForKey:@"childDirected" info:targetingInfo];
  if (childDirected != nil) {
    [request tagForChildDirectedTreatment:childDirected.boolValue];
  }

  NSString *requestAgent = [self targetingInfoStringForKey:@"requestAgent" info:targetingInfo];
  if (requestAgent != nil) {
    request.requestAgent = requestAgent;
  }

  return request;
}

- (NSDictionary *)argumentsMap {
  return @{@"id" : _mobileAdId};
}

- (NSString *)description {
  NSString *statusString = (NSString *)statusToString[[NSNumber numberWithInt:_status]];
  return [NSString
      stringWithFormat:@"%@ %@ mobileAdId:%@", super.description, statusString, _mobileAdId];
}
@end

@implementation BannerAd
GADBannerView *_banner;

+ (instancetype)withId:(NSNumber *)mobileAdId channel:(FlutterMethodChannel *)channel {
  MobileAd *ad = [MobileAd getAdForId:mobileAdId];
  return ad != nil ? (BannerAd *)ad : [[BannerAd alloc] initWithId:mobileAdId channel:channel];
}

- (void)loadWithUnitId:(NSString *)unitId targetingInfo:(NSDictionary *)targetingInfo {
  if (_status != CREATED) return;
  _status = LOADING;
  _banner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
  _banner.delegate = self;
  _banner.adUnitID = unitId;
  _banner.rootViewController = [MobileAd rootViewController];
  [_banner loadRequest:[self createLoadRequest:targetingInfo]];
}

- (void)show {
  if (_status == LOADING) {
    _status = PENDING;
    return;
  }
  if (_status != LOADED) return;

  UIView *screen = [MobileAd rootViewController].view;
  CGFloat x = screen.frame.size.width / 2 - _banner.frame.size.width / 2;
  CGFloat y = screen.frame.size.height - _banner.frame.size.height;
  _banner.frame = (CGRect){{x, y}, _banner.frame.size};
  [screen addSubview:_banner];
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  bool statusWasPending = _status == PENDING;
  _status = LOADED;
  [_channel invokeMethod:@"onAdLoaded" arguments:[self argumentsMap]];
  if (statusWasPending) [self show];
}

- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
  logWarning(@"adView:didFailToReceiveAdWithError: %@ (MobileAd %@)", [error localizedDescription],
             self);
  [_channel invokeMethod:@"onAdFailedToLoad" arguments:[self argumentsMap]];
}

- (void)adViewWillPresentScreen:(GADBannerView *)adView {
  [_channel invokeMethod:@"onAdClicked" arguments:[self argumentsMap]];
}

- (void)adViewWillDismissScreen:(GADBannerView *)adView {
  [_channel invokeMethod:@"onAdImpression" arguments:[self argumentsMap]];
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
  [_channel invokeMethod:@"onAdClosed" arguments:[self argumentsMap]];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
  [_channel invokeMethod:@"onAdLeftApplication" arguments:[self argumentsMap]];
}

- (void)dispose {
  if (_banner.superview) [_banner removeFromSuperview];
  _banner = nil;
  [super dispose];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ for: %@", super.description, _banner];
}
@end

@implementation InterstitialAd
GADInterstitial *_interstitial;

+ (instancetype)withId:(NSNumber *)mobileAdId channel:(FlutterMethodChannel *)channel {
  MobileAd *ad = [MobileAd getAdForId:mobileAdId];
  return ad != nil ? (InterstitialAd *)ad
                   : [[InterstitialAd alloc] initWithId:mobileAdId channel:channel];
}

- (void)loadWithUnitId:(NSString *)unitId targetingInfo:(NSDictionary *)targetingInfo {
  if (_status != CREATED) return;
  _status = LOADING;

  _interstitial = [[GADInterstitial alloc] initWithAdUnitID:unitId];
  _interstitial.delegate = self;
  [_interstitial loadRequest:[self createLoadRequest:targetingInfo]];
}

- (void)show {
  if (_status == LOADING) {
    _status = PENDING;
    return;
  }
  if (_status != LOADED) return;

  [_interstitial presentFromRootViewController:[MobileAd rootViewController]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
  bool statusWasPending = _status == PENDING;
  _status = LOADED;
  [_channel invokeMethod:@"onAdLoaded" arguments:[self argumentsMap]];
  if (statusWasPending) [self show];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
  logWarning(@"interstitial:didFailToReceiveAdWithError: %@ (MobileAd %@)",
             [error localizedDescription], self);
  [_channel invokeMethod:@"onAdFailedToLoad" arguments:[self argumentsMap]];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdClicked" arguments:[self argumentsMap]];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdImpression" arguments:[self argumentsMap]];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdClosed" arguments:[self argumentsMap]];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
  [_channel invokeMethod:@"onAdLeftApplication" arguments:[self argumentsMap]];
}

- (void)dispose {
  // It is not possible to hide/remove/destroy an AdMob interstitial Ad.
  _interstitial = nil;
  [super dispose];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"%@ for: %@", super.description, _interstitial];
}
@end
