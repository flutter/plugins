// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTThreadSafeTextureRegistry.h"

@implementation FLTThreadSafeTextureRegistry {
  NSObject<FlutterTextureRegistry> *_registry;
}

- (instancetype)initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *)registry {
  self = [super init];
  if (self) {
    _registry = registry;
  }
  return self;
}

- (int64_t)registerTextureSync:(NSObject<FlutterTexture> *)texture {
  if (!NSThread.isMainThread) {
    __block int64_t textureId;
    // We cannot use async API (with completion block) because completion block does not work for
    // separate functions (e.g. `dispose` and `create` are separately registered functions). It's
    // hard to tell if the developers had made implicit assumption of the synchronous nature of the
    // original API when implementing this plugin. Use dispatch_sync to keep
    // FlutterTextureRegistry's sychronous API, so that we don't introduce new potential race
    // conditions. We do not break priority inversion here since it's the background thread waiting
    // for main thread.
    dispatch_sync(dispatch_get_main_queue(), ^{
      textureId = [self->_registry registerTexture:texture];
    });
    return textureId;
  } else {
    return [_registry registerTexture:texture];
  }
}

- (void)textureFrameAvailable:(int64_t)textureId {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_registry textureFrameAvailable:textureId];
    });
  } else {
    [_registry textureFrameAvailable:textureId];
  }
}

- (void)unregisterTexture:(int64_t)textureId {
  if (!NSThread.isMainThread) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_registry unregisterTexture:textureId];
    });
  } else {
    [_registry unregisterTexture:textureId];
  }
}

@end
