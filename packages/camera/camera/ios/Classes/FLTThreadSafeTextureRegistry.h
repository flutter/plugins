// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Wrapper for FlutterTextureRegistry that always sends events on the main thread
 */
@interface FLTThreadSafeTextureRegistry : NSObject

/**
 * Creates a FLTThreadSafeTextureRegistry by wrapping an object conforming to
 * FlutterTextureRegistry.
 * @param registry The FlutterTextureRegistry object to be wrapped.
 */
- (instancetype)initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *)registry;

/**
 * Registers a `FlutterTexture` for usage in Flutter and returns an id that can be used to reference
 * that texture when calling into Flutter with channels. Textures must be registered on the
 * main thread. On success returns the pointer to the registered texture, else returns 0.
 *
 * Runs on main thread.
 */
- (int64_t)registerTextureSync:(NSObject<FlutterTexture> *)texture;

/**
 * Notifies Flutter that the content of the previously registered texture has been updated.
 *
 * This will trigger a call to `-[FlutterTexture copyPixelBuffer]` on the raster thread.
 *
 * Runs on main thread.
 */
- (void)textureFrameAvailable:(int64_t)textureId;

/**
 * Unregisters a `FlutterTexture` that has previously regeistered with `registerTexture:`. Textures
 * must be unregistered on the main thread.
 *
 * Runs on main thread.
 *
 * @param textureId The result that was previously returned from `registerTexture:`.
 */
- (void)unregisterTexture:(int64_t)textureId;

@end

NS_ASSUME_NONNULL_END
