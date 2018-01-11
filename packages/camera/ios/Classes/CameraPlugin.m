#import "CameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <libkern/OSAtomic.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

@interface FLTSavePhotoDelegate : NSObject<AVCapturePhotoCaptureDelegate>
@property(readonly, nonatomic) NSString *path;
@property(readonly, nonatomic) FlutterResult result;

- initWithPath:(NSString *)filename result:(FlutterResult)result;
@end

@implementation FLTSavePhotoDelegate {
  /// Used to keep the delegate alive until didFinishProcessingPhotoSampleBuffer.
  FLTSavePhotoDelegate *selfReference;
}

- initWithPath:(NSString *)path result:(FlutterResult)result {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _path = path;
  _result = result;
  selfReference = self;
  return self;
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer
                previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer
                        resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                         bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings
                                   error:(NSError *)error {
  selfReference = nil;
  if (error) {
    _result([error flutterError]);
    return;
  }
  NSData *data = [AVCapturePhotoOutput
      JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                            previewPhotoSampleBuffer:previewPhotoSampleBuffer];
  // TODO(sigurdm): Consider writing file asynchronously.
  bool success = [data writeToFile:_path atomically:YES];
  if (!success) {
    _result([FlutterError errorWithCode:@"IOError" message:@"Unable to write file" details:nil]);
    return;
  }
  _result(nil);
}
@end

@interface FLTCam
    : NSObject<FlutterTexture, AVCaptureVideoDataOutputSampleBufferDelegate, FlutterStreamHandler>
@property(readonly, nonatomic) int64_t textureId;
@property(nonatomic, copy) void (^onFrameAvailable)();
@property(nonatomic) FlutterEventChannel *eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(readonly, nonatomic) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCapturePhotoOutput *capturePhotoOutput;
@property(readonly) CVPixelBufferRef volatile latestPixelBuffer;
@property(readonly, nonatomic) CGSize previewSize;
@property(readonly, nonatomic) CGSize captureSize;

- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error;
- (void)start;
- (void)stop;
- (void)captureToFile:(NSString *)filename result:(FlutterResult)result;
@end

@implementation FLTCam
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _captureSession = [[AVCaptureSession alloc] init];
  AVCaptureSessionPreset preset;
  if ([resolutionPreset isEqualToString:@"high"]) {
    preset = AVCaptureSessionPresetHigh;
  } else if ([resolutionPreset isEqualToString:@"medium"]) {
    preset = AVCaptureSessionPresetMedium;
  } else {
    NSAssert([resolutionPreset isEqualToString:@"low"], @"Unknown resolution preset %@",
             resolutionPreset);
    preset = AVCaptureSessionPresetLow;
  }
  _captureSession.sessionPreset = preset;
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraName];
  NSError *localError = nil;
  AVCaptureInput *input =
      [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&localError];
  if (localError) {
    *error = localError;
    return nil;
  }
  CMVideoDimensions dimensions =
      CMVideoFormatDescriptionGetDimensions([[_captureDevice activeFormat] formatDescription]);
  _previewSize = CGSizeMake(dimensions.width, dimensions.height);

  AVCaptureVideoDataOutput *output = [AVCaptureVideoDataOutput new];
  output.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
  [output setAlwaysDiscardsLateVideoFrames:YES];
  [output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

  AVCaptureConnection *connection =
      [AVCaptureConnection connectionWithInputPorts:input.ports output:output];
  if ([_captureDevice position] == AVCaptureDevicePositionFront) {
    connection.videoMirrored = YES;
  }
  connection.videoOrientation = AVCaptureVideoOrientationPortrait;
  [_captureSession addInputWithNoConnections:input];
  [_captureSession addOutputWithNoConnections:output];
  [_captureSession addConnection:connection];
  _capturePhotoOutput = [AVCapturePhotoOutput new];
  [_captureSession addOutput:_capturePhotoOutput];
  return self;
}

- (void)start {
  [_captureSession startRunning];
}

- (void)stop {
  [_captureSession stopRunning];
}

- (void)captureToFile:(NSString *)path result:(FlutterResult)result {
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  [_capturePhotoOutput
      capturePhotoWithSettings:settings
                      delegate:[[FLTSavePhotoDelegate alloc] initWithPath:path result:result]];
}

- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection {
  CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CFRetain(newBuffer);
  CVPixelBufferRef old = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(old, newBuffer, (void **)&_latestPixelBuffer)) {
    old = _latestPixelBuffer;
  }
  if (old != nil) {
    CFRelease(old);
  }
  if (_onFrameAvailable) {
    _onFrameAvailable();
  }
}

- (void)close {
  [_captureSession stopRunning];
  for (AVCaptureInput *input in [_captureSession inputs]) {
    [_captureSession removeInput:input];
  }
  for (AVCaptureOutput *output in [_captureSession outputs]) {
    [_captureSession removeOutput:output];
  }
}

- (void)dealloc {
  if (_latestPixelBuffer) {
    CFRelease(_latestPixelBuffer);
  }
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }
  return pixelBuffer;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  _eventSink = events;
  return nil;
}
@end

@interface CameraPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) NSMutableDictionary *cams;
@end

@implementation CameraPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/camera"
                                  binaryMessenger:[registrar messenger]];
  CameraPlugin *instance =
      [[CameraPlugin alloc] initWithRegistry:[registrar textures] messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _messenger = messenger;
  _cams = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    for (NSNumber *textureId in _cams) {
      [_registry unregisterTexture:[textureId longLongValue]];
      [[_cams objectForKey:textureId] close];
    }
    [_cams removeAllObjects];
    result(nil);
  } else if ([@"list" isEqualToString:call.method]) {
    AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
        discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                              mediaType:AVMediaTypeVideo
                               position:AVCaptureDevicePositionUnspecified];
    NSArray<AVCaptureDevice *> *devices = discoverySession.devices;
    NSMutableArray<NSDictionary<NSString *, NSObject *> *> *reply =
        [[NSMutableArray alloc] initWithCapacity:devices.count];
    for (AVCaptureDevice *device in devices) {
      NSString *lensFacing;
      switch ([device position]) {
        case AVCaptureDevicePositionBack:
          lensFacing = @"back";
          break;
        case AVCaptureDevicePositionFront:
          lensFacing = @"front";
          break;
        case AVCaptureDevicePositionUnspecified:
          lensFacing = @"external";
          break;
      }
      [reply addObject:@{
        @"name" : [device uniqueID],
        @"lensFacing" : lensFacing,
      }];
    }
    result(reply);
  } else if ([@"create" isEqualToString:call.method]) {
    NSString *cameraName = call.arguments[@"cameraName"];
    NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
    NSError *error;
    FLTCam *cam = [[FLTCam alloc] initWithCameraName:cameraName
                                    resolutionPreset:resolutionPreset
                                               error:&error];
    if (error) {
      result([error flutterError]);
    } else {
      int64_t textureId = [_registry registerTexture:cam];
      _cams[@(textureId)] = cam;
      cam.onFrameAvailable = ^{
        [_registry textureFrameAvailable:textureId];
      };
      FlutterEventChannel *eventChannel = [FlutterEventChannel
          eventChannelWithName:[NSString
                                   stringWithFormat:@"flutter.io/cameraPlugin/cameraEvents%lld",
                                                    textureId]
               binaryMessenger:_messenger];
      [eventChannel setStreamHandler:cam];
      cam.eventChannel = eventChannel;
      result(@{
        @"textureId" : @(textureId),
        @"previewWidth" : @(cam.previewSize.width),
        @"previewHeight" : @(cam.previewSize.height),
        @"captureWidth" : @(cam.captureSize.width),
        @"captureHeight" : @(cam.captureSize.height),
      });
    }
  } else {
    NSDictionary *argsMap = call.arguments;
    NSUInteger textureId = ((NSNumber *)argsMap[@"textureId"]).unsignedIntegerValue;
    FLTCam *cam = _cams[@(textureId)];
    if ([@"start" isEqualToString:call.method]) {
      [cam start];
      result(nil);
    } else if ([@"stop" isEqualToString:call.method]) {
      [cam stop];
      result(nil);
    } else if ([@"capture" isEqualToString:call.method]) {
      [cam captureToFile:call.arguments[@"path"] result:result];
    } else if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:textureId];
      [cam close];
      [_cams removeObjectForKey:@(textureId)];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

@end
