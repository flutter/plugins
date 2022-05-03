
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFObjectHostApi.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFObjectHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFObjectHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (

    NSObject

        *)object
ForIdentifier:(NSNumber *)instanceId {
  return (

      NSObject

          *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  NSObject

      *object =

          [[NSObject alloc] init];

  [self.instanceManager addInstance:object withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager addInstance:configuration.object withIdentifier:instanceId.longValue];
}

- (void)addObserverForObjectWithIdentifier:(nonnull NSNumber *)instanceId

                                  observer:(nonnull NSObject *)observer

                                   keyPath:(nonnull NSString *)keyPath

                                   options:(nonnull NSArray<NSKeyValueObservingOptionsEnumData *> *)
                                               options

                                     error:(FlutterError *_Nullable *_Nonnull)error {
  [[self object ForIdentifier:instanceId] addObserver

                                                     :observer

                                              keyPath:keyPath

                                              options:options

  ];
}

- (void)removeObserverForObjectWithIdentifier:(nonnull NSNumber *)instanceId

                                     observer:(nonnull NSObject *)observer

                                      keyPath:(nonnull NSString *)keyPath

                                        error:(FlutterError *_Nullable *_Nonnull)error {
  [[self object ForIdentifier:instanceId] removeObserver

                                                        :observer

                                                 keyPath:keyPath

  ];
}

- (void)disposeObjectWithIdentifier:(nonnull NSNumber *)instanceId

                              error:(FlutterError *_Nullable *_Nonnull)error {
  [[self object ForIdentifier:instanceId] dispose

  ];
}

@end
