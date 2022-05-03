
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFScrollViewHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFScrollViewHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFScrollViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    UIScrollView

        *)scrollView
ForIdentifier:(NSNumber *)instanceId {
  return (

      UIScrollView

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  UIScrollView

      *scrollView =

          [[UIScrollView alloc] init];

  [self.instanceManager addInstance:scrollView withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.scrollView withIdentifier:instanceId.longValue];
}

- (void)contentOffsetForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId

                                           error:(FlutterError *_Nullable *_Nonnull)error {
  return [[self scrollView ForIdentifier:instanceId] getContentOffset

  ];
}

- (void)scrollByForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId

                                     offset:(nonnull NSNumber *)offset

                                      error:(FlutterError *_Nullable *_Nonnull)error {
  [[self scrollView ForIdentifier:instanceId] scrollBy

:offset

  ];
}

- (void)setContentOffsetForScrollViewWithIdentifier:(nonnull NSNumber *)instanceId

                                             offset:(nonnull NSNumber *)offset

                                              error:(FlutterError *_Nullable *_Nonnull)error {
  [[self scrollView ForIdentifier:instanceId] setContentOffset

:offset

  ];
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFUIViewHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFUIViewHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFUIViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    UIView

        *)uIView
ForIdentifier:(NSNumber *)instanceId {
  return (

      UIView

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  UIView

      *uIView =

          [[UIView alloc] init];

  [self.instanceManager addInstance:uIView withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.uIView withIdentifier:instanceId.longValue];
}

- (void)setBackgroundColorForViewWithIdentifier:(nonnull NSNumber *)instanceId

                                          color:(nullable NSNumber *)color

                                          error:(FlutterError *_Nullable *_Nonnull)error {
  [[self uIView ForIdentifier:instanceId] setBackgroundColor

:color

  ];
}

- (void)setOpaqueForViewWithIdentifier:(nonnull NSNumber *)instanceId

                                opaque:(nonnull NSNumber *)opaque

                                 error:(FlutterError *_Nullable *_Nonnull)error {
  [[self uIView ForIdentifier:instanceId] setOpaque

:opaque

  ];
}

@end
