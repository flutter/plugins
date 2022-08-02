// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v3.2.5), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@protocol FlutterMessageCodec;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class FFSFileSelectorConfig;

@interface FFSFileSelectorConfig : NSObject
/// `init` unavailable to enforce nonnull fields, see the `make` class method.
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)makeWithUtis:(NSArray<NSString *> *)utis
    allowMultiSelection:(NSNumber *)allowMultiSelection;
@property(nonatomic, strong) NSArray<NSString *> * utis;
@property(nonatomic, strong) NSNumber * allowMultiSelection;
@end

/// The codec used by FFSFileSelectorApi.
NSObject<FlutterMessageCodec> *FFSFileSelectorApiGetCodec(void);

@protocol FFSFileSelectorApi
- (void)openFileSelectorWithConfig:(FFSFileSelectorConfig *)config completion:(void(^)(NSArray<NSString *> *_Nullable, FlutterError *_Nullable))completion;
@end

extern void FFSFileSelectorApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FFSFileSelectorApi> *_Nullable api);

NS_ASSUME_NONNULL_END
