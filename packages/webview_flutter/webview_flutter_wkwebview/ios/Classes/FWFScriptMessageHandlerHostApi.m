// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFScriptMessageHandlerHostApi.h"
#import "FWFDataConverters.h"

@implementation FWFScriptMessageHandler
- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
}
@end

@interface FWFScriptMessageHandlerHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFScriptMessageHandlerHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFScriptMessageHandler *)scriptMessageHandlerForIdentifier:(NSNumber *)identifier {
  return (FWFScriptMessageHandler *)[self.instanceManager
      instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable *_Nonnull)error {
  FWFScriptMessageHandler *scriptMessageHandler = [[FWFScriptMessageHandler alloc] init];
  [self.instanceManager addDartCreatedInstance:scriptMessageHandler
                                withIdentifier:identifier.longValue];
}
@end
