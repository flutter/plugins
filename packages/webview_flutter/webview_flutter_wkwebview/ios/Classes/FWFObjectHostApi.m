// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFObjectHostApi.h"
#import "FWFDataConverters.h"

@interface FWFObjectFlutterApi ()
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFObjectFlutterApi
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}
@end

@implementation FWFObject
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _objectApi = [[FWFObjectFlutterApi alloc] initWithBinaryMessenger:binaryMessenger
                                                      instanceManager:instanceManager];
  }
  return self;
}
@end

@interface FWFObjectHostApiImpl ()
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFObjectHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (NSObject *)objectForIdentifier:(NSNumber *)instanceId {
  return (NSObject *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)addObserverForObjectWithIdentifier:(nonnull NSNumber *)instanceId
                        observerIdentifier:(nonnull NSNumber *)observer
                                   keyPath:(nonnull NSString *)keyPath
                                   options:
                                       (nonnull NSArray<FWFNSKeyValueObservingOptionsEnumData *> *)
                                           options
                                     error:(FlutterError *_Nullable *_Nonnull)error {
  NSKeyValueObservingOptions optionsInt = 0;
  for (FWFNSKeyValueObservingOptionsEnumData *data in options) {
    optionsInt |= FWFNSKeyValueObservingOptionsFromEnumData(data);
  }
  [[self objectForIdentifier:instanceId] addObserver:[self objectForIdentifier:observer]
                                          forKeyPath:keyPath
                                             options:optionsInt
                                             context:nil];
}

- (void)removeObserverForObjectWithIdentifier:(nonnull NSNumber *)instanceId
                           observerIdentifier:(nonnull NSNumber *)observer
                                      keyPath:(nonnull NSString *)keyPath
                                        error:(FlutterError *_Nullable *_Nonnull)error {
  [[self objectForIdentifier:instanceId] removeObserver:[self objectForIdentifier:observer]
                                             forKeyPath:keyPath];
}

- (void)disposeObjectWithIdentifier:(nonnull NSNumber *)instanceId
                              error:(FlutterError *_Nullable *_Nonnull)error {
  [self.instanceManager removeInstanceWithIdentifier:instanceId.longValue];
}
@end
