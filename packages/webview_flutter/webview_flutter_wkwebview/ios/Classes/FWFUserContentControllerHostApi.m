// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFUserContentControllerHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFUserContentControllerHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFUserContentControllerHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKUserContentController *)userContentControllerForIdentifier:(NSNumber *)instanceId {
  return (WKUserContentController *)[self.instanceManager
      instanceForIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.userContentController
                     withIdentifier:instanceId.longValue];
}

- (void)addScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)instanceId
                                         handlerIdentifier:(nonnull NSNumber *)handler
                                                    ofName:(nonnull NSString *)name
                                                     error:
                                                         (FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId]
      addScriptMessageHandler:(id<WKScriptMessageHandler>)[self.instanceManager
                                  instanceForIdentifier:handler.longValue]
                         name:name];
}

- (void)removeScriptMessageHandlerForControllerWithIdentifier:(nonnull NSNumber *)instanceId
                                                         name:(nonnull NSString *)name
                                                        error:(FlutterError *_Nullable *_Nonnull)
                                                                  error {
  [[self userContentControllerForIdentifier:instanceId] removeScriptMessageHandlerForName:name];
}

- (void)removeAllScriptMessageHandlersForControllerWithIdentifier:(nonnull NSNumber *)instanceId
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  if (@available(iOS 14.0, *)) {
    [[self userContentControllerForIdentifier:instanceId] removeAllScriptMessageHandlers];
  } else {
    *error = [FlutterError
        errorWithCode:@"FWFUnsupportedVersionError"
              message:@"removeAllScriptMessageHandlers is only supported on versions 14+."
              details:nil];
  }
}

- (void)addUserScriptForControllerWithIdentifier:(nonnull NSNumber *)instanceId
                                      userScript:(nonnull FWFWKUserScriptData *)userScript
                                           error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId]
      addUserScript:FWFWKUserScriptFromScriptData(userScript)];
}

- (void)removeAllUserScriptsForControllerWithIdentifier:(nonnull NSNumber *)instanceId
                                                  error:(FlutterError *_Nullable *_Nonnull)error {
  [[self userContentControllerForIdentifier:instanceId] removeAllUserScripts];
}

@end
