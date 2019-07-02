// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin+Internal.h"

@interface FLTCaptureVideoDataOutputSampleBufferDelegate ()
@property NativeTexture *texture;
@end

@implementation FLTCaptureVideoDataOutputSampleBufferDelegate
@synthesize handle;
- (instancetype _Nonnull)initWithPlatformTexture:(NativeTexture *_Nullable)texture
                                          handle:(NSNumber *)handle {
  self = [super init];
  if (self) {
    _texture = texture;
    self.handle = handle;
  }
  
  return self;
}

- (void)captureOutput:(AVCaptureOutput *)output
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection {
  CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

  if (_texture) {
    [_texture updatePixelBuffer:newBuffer];
  }
}

- (void)handleMethodCall:(FlutterMethodCall * _Nonnull)call result:(FlutterResult _Nonnull)result {
  result(FlutterMethodNotImplemented);
}
@end
