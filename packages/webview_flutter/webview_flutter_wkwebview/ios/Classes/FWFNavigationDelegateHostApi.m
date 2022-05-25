// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFNavigationDelegateHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@implementation FWFNavigationDelegate
@end

@interface FWFNavigationDelegateHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFNavigationDelegateHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (FWFNavigationDelegate *)navigationDelegateForIdentifier:(NSNumber *)identifier {
  return (FWFNavigationDelegate *)[self.instanceManager instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable *_Nonnull)error {
  FWFNavigationDelegate *navigationDelegate = [[FWFNavigationDelegate alloc] init];
  [self.instanceManager addDartCreatedInstance:navigationDelegate
                                withIdentifier:identifier.longValue];
}

- (void)setDidFinishNavigationForDelegateWithIdentifier:(nonnull NSNumber *)identifier
                                     functionIdentifier:(nullable NSNumber *)functionIdentifier
                                                  error:(FlutterError *_Nullable __autoreleasing
                                                             *_Nonnull)error {
  // TODO(bparrishMines): Implement when callback method design is finalized.
}
@end
