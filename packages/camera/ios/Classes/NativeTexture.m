// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin+Internal.h"
#import <libkern/OSAtomic.h>

@interface NativeTexture ()
@property CVPixelBufferRef volatile latestPixelBuffer;
@property _Nonnull id<FlutterTextureRegistry> registry;
@end

@implementation NativeTexture
@synthesize handle;
- (instancetype _Nonnull)initWithTextureRegistry:(NSObject<FlutterTextureRegistry> *)registry
                                          handle:(NSNumber *)handle {
  self = [self init];
  if (self) {
    _registry = registry;
    _textureId = [_registry registerTexture:self];
    self.handle = handle;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"NativeTexture#release" isEqualToString:call.method]) {
    [self release:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }

  return pixelBuffer;
}

- (void)updatePixelBuffer:(CVPixelBufferRef)pixelBuffer {
  CFRetain(pixelBuffer);

  CVPixelBufferRef old = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(old, pixelBuffer, (void **)&_latestPixelBuffer)) {
    old = _latestPixelBuffer;
  }

  if (old) {
    CFRelease(old);
  }

  [_registry textureFrameAvailable:_textureId];
}

- (void)release:(FlutterResult)result {
  [_registry unregisterTexture:_textureId];
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }

  [CameraPlugin removeMethodHandler:handle];

  result(nil);
}
@end
