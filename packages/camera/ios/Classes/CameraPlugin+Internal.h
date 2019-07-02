// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin.h"

@protocol MethodCallHandler
@required
@property NSNumber *_Nonnull handle;
- (void)handleMethodCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface CameraPlugin (Internal)
+ (void)addMethodHandler:(NSNumber *_Nonnull)handle
           methodHandler:(id<MethodCallHandler> _Nonnull)handler;
+ (void)removeMethodHandler:(NSNumber *_Nonnull)handle;
+ (id<MethodCallHandler> _Nullable)getHandler:(NSNumber *_Nullable)handle;
@end

@interface FLTCaptureDiscoverySession : NSObject
+ (NSArray<NSDictionary *> *_Nonnull)devices:(FlutterMethodCall *_Nonnull)call;
@end

@interface FLTCaptureSession : NSObject <MethodCallHandler>
+ (void)startRunning:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
+ (void)stopRunning:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface NativeTexture : NSObject <MethodCallHandler, FlutterTexture>
@property(readonly) int64_t textureId;
- (instancetype _Nonnull)initWithTextureRegistry:
                             (NSObject<FlutterTextureRegistry> *_Nonnull)registry
                                          handle:(NSNumber *_Nonnull)handle;
- (void)updatePixelBuffer:(CVPixelBufferRef _Nullable)pixelBuffer;
@end

@interface FLTCaptureVideoDataOutputSampleBufferDelegate
    : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, MethodCallHandler>
- (instancetype _Nonnull)initWithPlatformTexture:(NativeTexture *_Nullable)texture
                                          handle:(NSNumber *_Nonnull)handle;
@end

@interface FLTCaptureDevice : NSObject <MethodCallHandler>
+ (NSArray<NSDictionary *> *_Nonnull)getDevices:(FlutterMethodCall *_Nonnull)call;
- (instancetype _Nonnull)initWithCaptureDevice:(AVCaptureDevice *_Nonnull)device
                                        handle:(NSNumber *_Nonnull)handle;
+ (AVCaptureDevice *_Nonnull)deserialize:(NSDictionary *_Nonnull)data;
+ (NSDictionary *_Nonnull)serialize:(AVCaptureDevice *_Nonnull)device;
@end
