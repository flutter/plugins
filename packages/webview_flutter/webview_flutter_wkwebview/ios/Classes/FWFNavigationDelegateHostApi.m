// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFNavigationDelegateHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFNavigationDelegateFlutterApiImpl ()
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

- (void)didFinishNavigationFunction:(void (^)(WKWebView *, NSString *))function
                            webView:(WKWebView *)webView
                                URL:(NSString *)URL {
  long functionIdentifier = [self.instanceManager identifierForInstance:function];
  if (functionIdentifier != NSNotFound) {
    [self didFinishNavigationFunctionWithIdentifier:@(functionIdentifier)
                                  webViewIdentifier:@([self.instanceManager
                                                        identifierForInstance:webView])
                                                URL:URL
                                         completion:^(NSError *error) {
                                           if (error) {
                                             NSLog(@"%@", error.description);
                                           }
                                         }];
  }
}
@end

@interface FWFNavigationDelegate ()
@property void (^didFinishNavigation)(WKWebView *, NSString *);
@end

@implementation FWFNavigationDelegate
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [super initWithBinaryMessenger:binaryMessenger instanceManager:instanceManager];
  if (self) {
    _navigationDelegateApi =
        [[FWFNavigationDelegateFlutterApiImpl alloc] initWithBinaryMessenger:binaryMessenger
                                                             instanceManager:instanceManager];

    FWFNavigationDelegate __weak __block *weakSelf = self;
    _didFinishNavigation = ^(WKWebView *webView, NSString *URL) {
      [weakSelf.navigationDelegateApi didFinishNavigationFunction:weakSelf.didFinishNavigation
                                                          webView:webView
                                                              URL:URL];
    };
  }
  return self;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  self.didFinishNavigation(webView, webView.URL.absoluteString);
}
@end

@interface FWFNavigationDelegateHostApiImpl ()
@property(weak) id<FlutterBinaryMessenger> binaryMessenger;
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

- (FWFNavigationDelegate *)navigationDelegateForIdentifier:(NSNumber *)instanceId {
  return (FWFNavigationDelegate *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
    didFinishNavigationIdentifier:(nullable NSNumber *)didFinishNavigationInstanceId
                            error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  FWFNavigationDelegate *navigationDelegate =
      [[FWFNavigationDelegate alloc] initWithBinaryMessenger:self.binaryMessenger
                                             instanceManager:self.instanceManager];
  [self.instanceManager addInstance:navigationDelegate withIdentifier:instanceId.longValue];
  if (didFinishNavigationInstanceId) {
    [self.instanceManager addInstance:navigationDelegate.didFinishNavigation
                       withIdentifier:didFinishNavigationInstanceId.longValue];
  }
}
@end
