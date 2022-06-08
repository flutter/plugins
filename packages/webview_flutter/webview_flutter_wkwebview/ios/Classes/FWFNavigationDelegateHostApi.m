// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFNavigationDelegateHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFNavigationDelegateFlutterApiImpl ()
// This reference must be weak to prevent a circular reference with the objects it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (long)identifierForDelegate:(FWFNavigationDelegate *)instance {
  return [self.instanceManager identifierWithStrongReferenceForInstance:instance];
}

- (void)didFinishNavigationForDelegate:(FWFNavigationDelegate *)instance
                               webView:(WKWebView *)webView
                                   URL:(NSString *)URL {
  [self didFinishNavigationForDelegateWithIdentifier:@([self identifierForDelegate:instance])
                                   webViewIdentifier:
                                       @([self.instanceManager
                                           identifierWithStrongReferenceForInstance:webView])
                                                 URL:URL
                                          completion:^(NSError *error) {
                                            NSAssert(!error, @"%@", error);
                                          }];
}
@end

@implementation FWFNavigationDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _navigationDelegateAPI =
        [[FWFNavigationDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];
  }
  return self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [self.navigationDelegateAPI didFinishNavigationForDelegate:self
                                                     webView:webView
                                                         URL:webView.URL.absoluteString];
}
@end

@interface FWFNavigationDelegateHostApiImpl ()
@property(weak) id<FlutterBinaryMessenger> binaryMessenger;
// This reference must be weak to prevent a circular reference with the objects it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateHostApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _binaryMessenger = binaryMessenger;
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFNavigationDelegate *)navigationDelegateForIdentifier:(NSNumber *)identifier {
  return (FWFNavigationDelegate *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFNavigationDelegate *navigationDelegate =
      [[FWFNavigationDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addDartCreatedInstance:navigationDelegate
                                withIdentifier:identifier.longValue];
}
@end
