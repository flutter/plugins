/*iterate classes class*/
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"
#import "FWF__customValues_nameWithoutPrefix__HostApi.h"

/*if customValues_isProtocol*/
@implementation FWF__customValues_nameWithoutPrefix__
@end
/**/

@interface FWF__customValues_nameWithoutPrefix__HostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWF__customValues_nameWithoutPrefix__HostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (/*if customValues_isProtocol*/
   FWF__customValues_nameWithoutPrefix__
       /**/
       /*if! customValues_isProtocol*/
       __name__
           /**/
           *)/*replace :case=camel customValues_nameWithoutPrefix*/ name
    /**/ForIdentifier:(NSNumber *)instanceId {
  return (
      /*if customValues_isProtocol*/
      FWF__customValues_nameWithoutPrefix__
          /**/
          /*if! customValues_isProtocol*/
          __name__
              /**/
              *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  /*if customValues_isProtocol*/
  FWF__customValues_nameWithoutPrefix__
      /**/
      /*if! customValues_isProtocol*/
      __name__
          /**/
          * /*replace :case=camel customValues_nameWithoutPrefix*/ name /**/
      =
          /*if customValues_isProtocol*/
      [[FWF__customValues_nameWithoutPrefix__ alloc] init];
  /**/
  /*if! customValues_isProtocol*/
  [[__name__ alloc] init];
  /**/
  [self.instanceManager addInstance:/*replace :case=camel customValues_nameWithoutPrefix*/ name /**/
                     withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                             configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                                               error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  [self.instanceManager
         addInstance:configuration./*replace :case=camel customValues_nameWithoutPrefix*/ name /**/
      withIdentifier:instanceId.longValue];
}

/*iterate methods method*/
- (void)__customValues_objcName__:(nonnull NSNumber *)instanceId
                         /*iterate parameters parameter*/
                         __name__:(/*if type_nullable*/ nullable /**/ /*if! type_nullable*/
                                       nonnull /**/ __type_customValues_objcName__ *)__name__
                            /**/
                            error:(FlutterError *_Nullable *_Nonnull)error {
  /*if! customValues_returnsVoid*/ return /**/
      [[self /*replace :case=camel class_customValues_nameWithoutPrefix*/
              name /**/ ForIdentifier:instanceId] __name__
/*iterate :end=1 parameters parameter*/
:__name__
          /**/
          /*iterate :start=1 parameters parameter*/
          __name__:__name__
          /**/
  ];
}
/**/
@end
/**/