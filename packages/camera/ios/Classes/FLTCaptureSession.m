// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin+Internal.h"

@interface FLTCaptureSession ()
@property AVCaptureSession *session;
@property NSMutableDictionary<NSNumber *, AVCaptureInput *> *inputs;
@property NSMutableDictionary<NSNumber *, AVCaptureOutput *> *outputs;
@property NSMutableArray<NSNumber *> *handlerHandles;
@property FLTCaptureVideoDataOutputSampleBufferDelegate *delegate;
@end

@implementation FLTCaptureSession
@synthesize handle;
- (instancetype _Nonnull)initWithSession:(AVCaptureSession *)session handle:(NSNumber *)handle {
  self = [super init];
  if (self) {
    _session = session;
    _inputs = [NSMutableDictionary new];
    _outputs = [NSMutableDictionary new];
    _handlerHandles = [NSMutableArray new];
    self.handle = handle;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  if ([@"CaptureSession#addOutput" isEqualToString:call.method]) {
    [self addOutput:call result:result];
  } else if ([@"CaptureSession#removeOutput" isEqualToString:call.method]) {
    [self removeOutput:call result:result];
  } else if ([@"CaptureSession#addInput" isEqualToString:call.method]) {
    [self addInput:call result:result];
  } else if ([@"CaptureSession#removeInput" isEqualToString:call.method]) {
    [self removeInput:call result:result];
  } else if ([@"CaptureSession#stopRunning" isEqualToString:call.method]) {
    [self stopRunning:call];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

+ (void)startRunning:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  AVCaptureSession *session = [AVCaptureSession new];
  NSNumber *sessionHandle = call.arguments[@"sessionHandle"];
  FLTCaptureSession *fltSession = [[FLTCaptureSession alloc] initWithSession:session
                                                                      handle:sessionHandle];

  NSArray<NSDictionary *> *inputs = call.arguments[@"inputs"];
  for (NSDictionary *inputData in inputs) {
    NSString *className = inputData[@"class"];
    AVCaptureInput *input;

    if ([@"_CaptureInputClass.captureDeviceInput" isEqualToString:className]) {
      NSDictionary *deviceData = inputData[@"device"];
      AVCaptureDevice *device = [FLTCaptureDevice deserialize:deviceData];
      input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];

      NSNumber *handle = deviceData[@"handle"];
      FLTCaptureDevice *fltDevice = [[FLTCaptureDevice alloc] initWithCaptureDevice:device
                                                                             handle:handle];

      [fltSession.handlerHandles addObject:handle];
      [CameraPlugin addMethodHandler:handle methodHandler:fltDevice];
    }

    [session addInput:input];

    NSNumber *handle = inputData[@"handle"];
    fltSession.inputs[handle] = input;
  }

  NSArray<NSDictionary *> *outputs = call.arguments[@"outputs"];
  for (NSDictionary *outputData in outputs) {
    NSString *className = outputData[@"class"];
    AVCaptureOutput *output;

    if ([@"_CaptureOutputClass.captureVideoDataOutput" isEqualToString:className]) {
      AVCaptureVideoDataOutput *dataOutput = [AVCaptureVideoDataOutput new];

      NSString *formatStr = outputData[@"formatType"];
      if (formatStr) {
        FourCharCode pixelFormat = 0;
        if ([@"PixelFormatType.bgra32" isEqualToString:formatStr]) {
          pixelFormat = kCVPixelFormatType_32BGRA;
        }

        dataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(pixelFormat)};
      }

      NSDictionary *delegateData = outputData[@"delegate"];
      if (delegateData) {
        NSDictionary *textureData = delegateData[@"nativeTexture"];
        NSNumber *textureHandle = textureData[@"handle"];

        NativeTexture *texture = nil;
        if (textureHandle) {
          texture = (NativeTexture *)[CameraPlugin getHandler:textureHandle];
        }

        NSNumber *handle = outputData[@"handle"];
        FLTCaptureVideoDataOutputSampleBufferDelegate *delegate =
            [[FLTCaptureVideoDataOutputSampleBufferDelegate alloc] initWithPlatformTexture:texture
                                                                                    handle:handle];

        [dataOutput setSampleBufferDelegate:delegate queue:dispatch_get_main_queue()];

        [fltSession.handlerHandles addObject:handle];
        [CameraPlugin addMethodHandler:handle methodHandler:delegate];
        fltSession.delegate = delegate;
      }

      output = dataOutput;
    }

    [session addOutput:output];

    NSNumber *handle = outputData[@"handle"];
    fltSession.outputs[handle] = output;
  }

  [CameraPlugin addMethodHandler:sessionHandle methodHandler:fltSession];

  [session startRunning];
  result(nil);
}

+ (void)stopRunning:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  NSNumber *handle = call.arguments[@"handle"];
  id<MethodCallHandler> handler = [CameraPlugin getHandler:handle];

  if (handler) {
    [handler handleMethodCall:call result:result];
  } else {
    result(nil);
  }
}

- (void)stopRunning:(FlutterMethodCall *_Nonnull)call {
  [_session stopRunning];

  for (NSNumber *handle in _handlerHandles) {
    [CameraPlugin removeMethodHandler:handle];
  }

  [CameraPlugin removeMethodHandler:handle];
}

- (void)addOutput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
}

- (void)removeOutput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
}

- (void)addInput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
}

- (void)removeInput:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
}
@end
