// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterMock.h"

@implementation MockRegistrar

- (void)addApplicationDelegate:(nonnull NSObject<FlutterPlugin> *)delegate {
}

- (void)addMethodCallDelegate:(nonnull NSObject<FlutterPlugin> *)delegate
                      channel:(nonnull FlutterMethodChannel *)channel {
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset {
  return @"";
}

- (nonnull NSString *)lookupKeyForAsset:(nonnull NSString *)asset
                            fromPackage:(nonnull NSString *)package {
  return @"";
}

- (nonnull NSObject<FlutterBinaryMessenger> *)messenger {
  return [[MockBinaryMessenger alloc] init];
}

- (void)publish:(nonnull NSObject *)value {
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                     withId:(nonnull NSString *)factoryId {
}

- (void)registerViewFactory:(nonnull NSObject<FlutterPlatformViewFactory> *)factory
                              withId:(nonnull NSString *)factoryId
    gestureRecognizersBlockingPolicy:
        (FlutterPlatformViewGestureRecognizersBlockingPolicy)gestureRecognizersBlockingPolicy {
}

- (nonnull NSObject<FlutterTextureRegistry> *)textures {
  return [[MockTextureRegistry alloc] init];
}

@end

@implementation MockBinaryMessenger

- (void)cleanUpConnection:(FlutterBinaryMessengerConnection)connection {
}

- (void)sendOnChannel:(nonnull NSString *)channel message:(NSData *_Nullable)message {
}

- (void)sendOnChannel:(nonnull NSString *)channel
              message:(NSData *_Nullable)message
          binaryReply:(FlutterBinaryReply _Nullable)callback {
}

- (FlutterBinaryMessengerConnection)setMessageHandlerOnChannel:(nonnull NSString *)channel
                                          binaryMessageHandler:
                                              (FlutterBinaryMessageHandler _Nullable)handler {
  return 0;
}

@end

@implementation MockTextureRegistry

- (int64_t)registerTexture:(nonnull NSObject<FlutterTexture> *)texture {
  return 0;
}

- (void)textureFrameAvailable:(int64_t)textureId {
}

- (void)unregisterTexture:(int64_t)textureId {
}

@end
