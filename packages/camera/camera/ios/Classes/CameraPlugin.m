// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "CameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>
#import <libkern/OSAtomic.h>
#import <uuid/uuid.h>

static FlutterError *getFlutterError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.localizedDescription
                             details:error.domain];
}

@interface FLTSavePhotoDelegate : NSObject <AVCapturePhotoCaptureDelegate>
@property(readonly, nonatomic) NSString *path;
@property(readonly, nonatomic) FlutterResult result;
@end

@interface FLTImageStreamHandler : NSObject <FlutterStreamHandler>
@property FlutterEventSink eventSink;
@end

@implementation FLTImageStreamHandler

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

@implementation FLTSavePhotoDelegate {
  /// Used to keep the delegate alive until didFinishProcessingPhotoSampleBuffer.
  FLTSavePhotoDelegate *selfReference;
}

- initWithPath:(NSString *)path result:(FlutterResult)result {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _path = path;
  selfReference = self;
  _result = result;
  return self;
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer
                previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer
                        resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                         bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings
                                   error:(NSError *)error API_AVAILABLE(ios(10)) {
  selfReference = nil;
  if (error) {
    _result(getFlutterError(error));
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
  _result(_path);
}

- (void)captureOutput:(AVCapturePhotoOutput *)output
    didFinishProcessingPhoto:(AVCapturePhoto *)photo
                       error:(NSError *)error API_AVAILABLE(ios(11.0)) {
  selfReference = nil;
  if (error) {
    _result(getFlutterError(error));
    return;
  }

  NSData *photoData = [photo fileDataRepresentation];

  bool success = [photoData writeToFile:_path atomically:YES];
  if (!success) {
    _result([FlutterError errorWithCode:@"IOError" message:@"Unable to write file" details:nil]);
    return;
  }
  _result(_path);
}
@end

// Mirrors FlashMode in flash_mode.dart
typedef enum {
  FlashModeOff,
  FlashModeAuto,
  FlashModeAlways,
  FlashModeTorch,
} FlashMode;

static FlashMode getFlashModeForString(NSString *mode) {
  if ([mode isEqualToString:@"off"]) {
    return FlashModeOff;
  } else if ([mode isEqualToString:@"auto"]) {
    return FlashModeAuto;
  } else if ([mode isEqualToString:@"always"]) {
    return FlashModeAlways;
  } else if ([mode isEqualToString:@"torch"]) {
    return FlashModeTorch;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown flash mode %@", mode]
                                     }];
    @throw error;
  }
}

static OSType getVideoFormatFromString(NSString *videoFormatString) {
  if ([videoFormatString isEqualToString:@"bgra8888"]) {
    return kCVPixelFormatType_32BGRA;
  } else if ([videoFormatString isEqualToString:@"yuv420"]) {
    return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
  } else {
    NSLog(@"The selected imageFormatGroup is not supported by iOS. Defaulting to brga8888");
    return kCVPixelFormatType_32BGRA;
  }
}

static AVCaptureFlashMode getAVCaptureFlashModeForFlashMode(FlashMode mode) {
  switch (mode) {
    case FlashModeOff:
      return AVCaptureFlashModeOff;
    case FlashModeAuto:
      return AVCaptureFlashModeAuto;
    case FlashModeAlways:
      return AVCaptureFlashModeOn;
    case FlashModeTorch:
    default:
      return -1;
  }
}

// Mirrors ExposureMode in camera.dart
typedef enum {
  ExposureModeAuto,
  ExposureModeLocked,

} ExposureMode;

static NSString *getStringForExposureMode(ExposureMode mode) {
  switch (mode) {
    case ExposureModeAuto:
      return @"auto";
    case ExposureModeLocked:
      return @"locked";
  }
  NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                       code:NSURLErrorUnknown
                                   userInfo:@{
                                     NSLocalizedDescriptionKey : [NSString
                                         stringWithFormat:@"Unknown string for exposure mode"]
                                   }];
  @throw error;
}

static ExposureMode getExposureModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return ExposureModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return ExposureModeLocked;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown exposure mode %@", mode]
                                     }];
    @throw error;
  }
}

static UIDeviceOrientation getUIDeviceOrientationForString(NSString *orientation) {
  if ([orientation isEqualToString:@"portraitDown"]) {
    return UIDeviceOrientationPortraitUpsideDown;
  } else if ([orientation isEqualToString:@"landscapeLeft"]) {
    return UIDeviceOrientationLandscapeRight;
  } else if ([orientation isEqualToString:@"landscapeRight"]) {
    return UIDeviceOrientationLandscapeLeft;
  } else if ([orientation isEqualToString:@"portraitUp"]) {
    return UIDeviceOrientationPortrait;
  } else {
    NSError *error = [NSError
        errorWithDomain:NSCocoaErrorDomain
                   code:NSURLErrorUnknown
               userInfo:@{
                 NSLocalizedDescriptionKey :
                     [NSString stringWithFormat:@"Unknown device orientation %@", orientation]
               }];
    @throw error;
  }
}

static NSString *getStringForUIDeviceOrientation(UIDeviceOrientation orientation) {
  switch (orientation) {
    case UIDeviceOrientationPortraitUpsideDown:
      return @"portraitDown";
    case UIDeviceOrientationLandscapeRight:
      return @"landscapeLeft";
    case UIDeviceOrientationLandscapeLeft:
      return @"landscapeRight";
    case UIDeviceOrientationPortrait:
    default:
      return @"portraitUp";
      break;
  };
}

// Mirrors FocusMode in camera.dart
typedef enum {
  FocusModeAuto,
  FocusModeLocked,
} FocusMode;

static NSString *getStringForFocusMode(FocusMode mode) {
  switch (mode) {
    case FocusModeAuto:
      return @"auto";
    case FocusModeLocked:
      return @"locked";
  }
  NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                       code:NSURLErrorUnknown
                                   userInfo:@{
                                     NSLocalizedDescriptionKey : [NSString
                                         stringWithFormat:@"Unknown string for focus mode"]
                                   }];
  @throw error;
}

static FocusMode getFocusModeForString(NSString *mode) {
  if ([mode isEqualToString:@"auto"]) {
    return FocusModeAuto;
  } else if ([mode isEqualToString:@"locked"]) {
    return FocusModeLocked;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown focus mode %@", mode]
                                     }];
    @throw error;
  }
}

// Mirrors ResolutionPreset in camera.dart
typedef enum {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
  ultraHigh,
  max,
} ResolutionPreset;

static ResolutionPreset getResolutionPresetForString(NSString *preset) {
  if ([preset isEqualToString:@"veryLow"]) {
    return veryLow;
  } else if ([preset isEqualToString:@"low"]) {
    return low;
  } else if ([preset isEqualToString:@"medium"]) {
    return medium;
  } else if ([preset isEqualToString:@"high"]) {
    return high;
  } else if ([preset isEqualToString:@"veryHigh"]) {
    return veryHigh;
  } else if ([preset isEqualToString:@"ultraHigh"]) {
    return ultraHigh;
  } else if ([preset isEqualToString:@"max"]) {
    return max;
  } else {
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:NSURLErrorUnknown
                                     userInfo:@{
                                       NSLocalizedDescriptionKey : [NSString
                                           stringWithFormat:@"Unknown resolution preset %@", preset]
                                     }];
    @throw error;
  }
}

@interface FLTCam : NSObject <FlutterTexture,
                              AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate>
@property(readonly, nonatomic) int64_t textureId;
@property(nonatomic, copy) void (^onFrameAvailable)(void);
@property BOOL enableAudio;
@property(nonatomic) FLTImageStreamHandler *imageStreamHandler;
@property(nonatomic) FlutterMethodChannel *methodChannel;
@property(readonly, nonatomic) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCapturePhotoOutput *capturePhotoOutput API_AVAILABLE(ios(10));
@property(readonly, nonatomic) AVCaptureVideoDataOutput *captureVideoOutput;
@property(readonly, nonatomic) AVCaptureInput *captureVideoInput;
@property(readonly) CVPixelBufferRef volatile latestPixelBuffer;
@property(readonly, nonatomic) CGSize previewSize;
@property(readonly, nonatomic) CGSize captureSize;
@property(strong, nonatomic) AVAssetWriter *videoWriter;
@property(strong, nonatomic) AVAssetWriterInput *videoWriterInput;
@property(strong, nonatomic) AVAssetWriterInput *audioWriterInput;
@property(strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferAdaptor;
@property(strong, nonatomic) AVCaptureVideoDataOutput *videoOutput;
@property(strong, nonatomic) AVCaptureAudioDataOutput *audioOutput;
@property(strong, nonatomic) NSString *videoRecordingPath;
@property(assign, nonatomic) BOOL isRecording;
@property(assign, nonatomic) BOOL isRecordingPaused;
@property(assign, nonatomic) BOOL videoIsDisconnected;
@property(assign, nonatomic) BOOL audioIsDisconnected;
@property(assign, nonatomic) BOOL isAudioSetup;
@property(assign, nonatomic) BOOL isStreamingImages;
@property(assign, nonatomic) BOOL isPreviewPaused;
@property(assign, nonatomic) ResolutionPreset resolutionPreset;
@property(assign, nonatomic) ExposureMode exposureMode;
@property(assign, nonatomic) FocusMode focusMode;
@property(assign, nonatomic) FlashMode flashMode;
@property(assign, nonatomic) UIDeviceOrientation lockedCaptureOrientation;
@property(assign, nonatomic) CMTime lastVideoSampleTime;
@property(assign, nonatomic) CMTime lastAudioSampleTime;
@property(assign, nonatomic) CMTime videoTimeOffset;
@property(assign, nonatomic) CMTime audioTimeOffset;
@property(nonatomic) CMMotionManager *motionManager;
@property AVAssetWriterInputPixelBufferAdaptor *videoAdaptor;
@end

@implementation FLTCam {
  dispatch_queue_t _dispatchQueue;
  UIDeviceOrientation _deviceOrientation;
}
// Format used for video and image streaming.
FourCharCode videoFormat = kCVPixelFormatType_32BGRA;
NSString *const errorMethod = @"error";

- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                       enableAudio:(BOOL)enableAudio
                       orientation:(UIDeviceOrientation)orientation
                     dispatchQueue:(dispatch_queue_t)dispatchQueue
                             error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  @try {
    _resolutionPreset = getResolutionPresetForString(resolutionPreset);
  } @catch (NSError *e) {
    *error = e;
  }
  _enableAudio = enableAudio;
  _dispatchQueue = dispatchQueue;
  _captureSession = [[AVCaptureSession alloc] init];
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraName];
  _flashMode = _captureDevice.hasFlash ? FlashModeAuto : FlashModeOff;
  _exposureMode = ExposureModeAuto;
  _focusMode = FocusModeAuto;
  _lockedCaptureOrientation = UIDeviceOrientationUnknown;
  _deviceOrientation = orientation;

  NSError *localError = nil;
  _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                             error:&localError];

  if (localError) {
    *error = localError;
    return nil;
  }

  _captureVideoOutput = [AVCaptureVideoDataOutput new];
  _captureVideoOutput.videoSettings =
      @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(videoFormat)};
  [_captureVideoOutput setAlwaysDiscardsLateVideoFrames:YES];
  [_captureVideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];

  AVCaptureConnection *connection =
      [AVCaptureConnection connectionWithInputPorts:_captureVideoInput.ports
                                             output:_captureVideoOutput];

  if ([_captureDevice position] == AVCaptureDevicePositionFront) {
    connection.videoMirrored = YES;
  }

  [_captureSession addInputWithNoConnections:_captureVideoInput];
  [_captureSession addOutputWithNoConnections:_captureVideoOutput];
  [_captureSession addConnection:connection];

  if (@available(iOS 10.0, *)) {
    _capturePhotoOutput = [AVCapturePhotoOutput new];
    [_capturePhotoOutput setHighResolutionCaptureEnabled:YES];
    [_captureSession addOutput:_capturePhotoOutput];
  }
  _motionManager = [[CMMotionManager alloc] init];
  [_motionManager startAccelerometerUpdates];

  [self setCaptureSessionPreset:_resolutionPreset];
  [self updateOrientation];

  return self;
}

- (void)start {
  [_captureSession startRunning];
}

- (void)stop {
  [_captureSession stopRunning];
}

- (void)setDeviceOrientation:(UIDeviceOrientation)orientation {
  if (_deviceOrientation == orientation) {
    return;
  }

  _deviceOrientation = orientation;
  [self updateOrientation];
}

- (void)updateOrientation {
  if (_isRecording) {
    return;
  }

  UIDeviceOrientation orientation = (_lockedCaptureOrientation != UIDeviceOrientationUnknown)
                                        ? _lockedCaptureOrientation
                                        : _deviceOrientation;

  [self updateOrientation:orientation forCaptureOutput:_capturePhotoOutput];
  [self updateOrientation:orientation forCaptureOutput:_captureVideoOutput];
}

- (void)updateOrientation:(UIDeviceOrientation)orientation
         forCaptureOutput:(AVCaptureOutput *)captureOutput {
  if (!captureOutput) {
    return;
  }

  AVCaptureConnection *connection = [captureOutput connectionWithMediaType:AVMediaTypeVideo];
  if (connection && connection.isVideoOrientationSupported) {
    connection.videoOrientation = [self getVideoOrientationForDeviceOrientation:orientation];
  }
}

- (void)captureToFile:(FlutterResult)result API_AVAILABLE(ios(10)) {
  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
  if (_resolutionPreset == max) {
    [settings setHighResolutionPhotoEnabled:YES];
  }

  AVCaptureFlashMode avFlashMode = getAVCaptureFlashModeForFlashMode(_flashMode);
  if (avFlashMode != -1) {
    [settings setFlashMode:avFlashMode];
  }
  NSError *error;
  NSString *path = [self getTemporaryFilePathWithExtension:@"jpg"
                                                 subfolder:@"pictures"
                                                    prefix:@"CAP_"
                                                     error:error];
  if (error) {
    result(getFlutterError(error));
    return;
  }

  [_capturePhotoOutput capturePhotoWithSettings:settings
                                       delegate:[[FLTSavePhotoDelegate alloc] initWithPath:path
                                                                                    result:result]];
}

- (AVCaptureVideoOrientation)getVideoOrientationForDeviceOrientation:
    (UIDeviceOrientation)deviceOrientation {
  if (deviceOrientation == UIDeviceOrientationPortrait) {
    return AVCaptureVideoOrientationPortrait;
  } else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
    // Note: device orientation is flipped compared to video orientation. When UIDeviceOrientation
    // is landscape left the video orientation should be landscape right.
    return AVCaptureVideoOrientationLandscapeRight;
  } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
    // Note: device orientation is flipped compared to video orientation. When UIDeviceOrientation
    // is landscape right the video orientation should be landscape left.
    return AVCaptureVideoOrientationLandscapeLeft;
  } else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
    return AVCaptureVideoOrientationPortraitUpsideDown;
  } else {
    return AVCaptureVideoOrientationPortrait;
  }
}

- (NSString *)getTemporaryFilePathWithExtension:(NSString *)extension
                                      subfolder:(NSString *)subfolder
                                         prefix:(NSString *)prefix
                                          error:(NSError *)error {
  NSString *docDir =
      NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
  NSString *fileDir =
      [[docDir stringByAppendingPathComponent:@"camera"] stringByAppendingPathComponent:subfolder];
  NSString *fileName = [prefix stringByAppendingString:[[NSUUID UUID] UUIDString]];
  NSString *file =
      [[fileDir stringByAppendingPathComponent:fileName] stringByAppendingPathExtension:extension];

  NSFileManager *fm = [NSFileManager defaultManager];
  if (![fm fileExistsAtPath:fileDir]) {
    [[NSFileManager defaultManager] createDirectoryAtPath:fileDir
                              withIntermediateDirectories:true
                                               attributes:nil
                                                    error:&error];
    if (error) {
      return nil;
    }
  }

  return file;
}

- (void)setCaptureSessionPreset:(ResolutionPreset)resolutionPreset {
  switch (resolutionPreset) {
    case max:
    case ultraHigh:
      if (@available(iOS 9.0, *)) {
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset3840x2160]) {
          _captureSession.sessionPreset = AVCaptureSessionPreset3840x2160;
          _previewSize = CGSizeMake(3840, 2160);
          break;
        }
      }
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        _previewSize =
            CGSizeMake(_captureDevice.activeFormat.highResolutionStillImageDimensions.width,
                       _captureDevice.activeFormat.highResolutionStillImageDimensions.height);
        break;
      }
    case veryHigh:
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        _previewSize = CGSizeMake(1920, 1080);
        break;
      }
    case high:
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        _previewSize = CGSizeMake(1280, 720);
        break;
      }
    case medium:
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        _previewSize = CGSizeMake(640, 480);
        break;
      }
    case low:
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset352x288;
        _previewSize = CGSizeMake(352, 288);
        break;
      }
    default:
      if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetLow]) {
        _captureSession.sessionPreset = AVCaptureSessionPresetLow;
        _previewSize = CGSizeMake(352, 288);
      } else {
        NSError *error =
            [NSError errorWithDomain:NSCocoaErrorDomain
                                code:NSURLErrorUnknown
                            userInfo:@{
                              NSLocalizedDescriptionKey :
                                  @"No capture session available for current capture session."
                            }];
        @throw error;
      }
  }
}

- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection {
  if (output == _captureVideoOutput) {
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
  if (!CMSampleBufferDataIsReady(sampleBuffer)) {
    [_methodChannel invokeMethod:errorMethod
                       arguments:@"sample buffer is not ready. Skipping sample"];
    return;
  }
  if (_isStreamingImages) {
    if (_imageStreamHandler.eventSink) {
      CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
      CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

      size_t imageWidth = CVPixelBufferGetWidth(pixelBuffer);
      size_t imageHeight = CVPixelBufferGetHeight(pixelBuffer);

      NSMutableArray *planes = [NSMutableArray array];

      const Boolean isPlanar = CVPixelBufferIsPlanar(pixelBuffer);
      size_t planeCount;
      if (isPlanar) {
        planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
      } else {
        planeCount = 1;
      }

      for (int i = 0; i < planeCount; i++) {
        void *planeAddress;
        size_t bytesPerRow;
        size_t height;
        size_t width;

        if (isPlanar) {
          planeAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, i);
          bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i);
          height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i);
          width = CVPixelBufferGetWidthOfPlane(pixelBuffer, i);
        } else {
          planeAddress = CVPixelBufferGetBaseAddress(pixelBuffer);
          bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
          height = CVPixelBufferGetHeight(pixelBuffer);
          width = CVPixelBufferGetWidth(pixelBuffer);
        }

        NSNumber *length = @(bytesPerRow * height);
        NSData *bytes = [NSData dataWithBytes:planeAddress length:length.unsignedIntegerValue];

        NSMutableDictionary *planeBuffer = [NSMutableDictionary dictionary];
        planeBuffer[@"bytesPerRow"] = @(bytesPerRow);
        planeBuffer[@"width"] = @(width);
        planeBuffer[@"height"] = @(height);
        planeBuffer[@"bytes"] = [FlutterStandardTypedData typedDataWithBytes:bytes];

        [planes addObject:planeBuffer];
      }

      NSMutableDictionary *imageBuffer = [NSMutableDictionary dictionary];
      imageBuffer[@"width"] = [NSNumber numberWithUnsignedLong:imageWidth];
      imageBuffer[@"height"] = [NSNumber numberWithUnsignedLong:imageHeight];
      imageBuffer[@"format"] = @(videoFormat);
      imageBuffer[@"planes"] = planes;
      imageBuffer[@"lensAperture"] = [NSNumber numberWithFloat:[_captureDevice lensAperture]];
      Float64 exposureDuration = CMTimeGetSeconds([_captureDevice exposureDuration]);
      Float64 nsExposureDuration = 1000000000 * exposureDuration;
      imageBuffer[@"sensorExposureTime"] = [NSNumber numberWithInt:nsExposureDuration];
      imageBuffer[@"sensorSensitivity"] = [NSNumber numberWithFloat:[_captureDevice ISO]];

      _imageStreamHandler.eventSink(imageBuffer);

      CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    }
  }
  if (_isRecording && !_isRecordingPaused) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      [_methodChannel invokeMethod:errorMethod
                         arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
      return;
    }

    CFRetain(sampleBuffer);
    CMTime currentSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);

    if (_videoWriter.status != AVAssetWriterStatusWriting) {
      [_videoWriter startWriting];
      [_videoWriter startSessionAtSourceTime:currentSampleTime];
    }

    if (output == _captureVideoOutput) {
      if (_videoIsDisconnected) {
        _videoIsDisconnected = NO;

        if (_videoTimeOffset.value == 0) {
          _videoTimeOffset = CMTimeSubtract(currentSampleTime, _lastVideoSampleTime);
        } else {
          CMTime offset = CMTimeSubtract(currentSampleTime, _lastVideoSampleTime);
          _videoTimeOffset = CMTimeAdd(_videoTimeOffset, offset);
        }

        return;
      }

      _lastVideoSampleTime = currentSampleTime;

      CVPixelBufferRef nextBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
      CMTime nextSampleTime = CMTimeSubtract(_lastVideoSampleTime, _videoTimeOffset);
      [_videoAdaptor appendPixelBuffer:nextBuffer withPresentationTime:nextSampleTime];
    } else {
      CMTime dur = CMSampleBufferGetDuration(sampleBuffer);

      if (dur.value > 0) {
        currentSampleTime = CMTimeAdd(currentSampleTime, dur);
      }

      if (_audioIsDisconnected) {
        _audioIsDisconnected = NO;

        if (_audioTimeOffset.value == 0) {
          _audioTimeOffset = CMTimeSubtract(currentSampleTime, _lastAudioSampleTime);
        } else {
          CMTime offset = CMTimeSubtract(currentSampleTime, _lastAudioSampleTime);
          _audioTimeOffset = CMTimeAdd(_audioTimeOffset, offset);
        }

        return;
      }

      _lastAudioSampleTime = currentSampleTime;

      if (_audioTimeOffset.value != 0) {
        CFRelease(sampleBuffer);
        sampleBuffer = [self adjustTime:sampleBuffer by:_audioTimeOffset];
      }

      [self newAudioSample:sampleBuffer];
    }

    CFRelease(sampleBuffer);
  }
}

- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset CF_RETURNS_RETAINED {
  CMItemCount count;
  CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
  CMSampleTimingInfo *pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
  CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
  for (CMItemCount i = 0; i < count; i++) {
    pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
    pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
  }
  CMSampleBufferRef sout;
  CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
  free(pInfo);
  return sout;
}

- (void)newVideoSample:(CMSampleBufferRef)sampleBuffer {
  if (_videoWriter.status != AVAssetWriterStatusWriting) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      [_methodChannel invokeMethod:errorMethod
                         arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
    }
    return;
  }
  if (_videoWriterInput.readyForMoreMediaData) {
    if (![_videoWriterInput appendSampleBuffer:sampleBuffer]) {
      [_methodChannel
          invokeMethod:errorMethod
             arguments:[NSString stringWithFormat:@"%@", @"Unable to write to video input"]];
    }
  }
}

- (void)newAudioSample:(CMSampleBufferRef)sampleBuffer {
  if (_videoWriter.status != AVAssetWriterStatusWriting) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      [_methodChannel invokeMethod:errorMethod
                         arguments:[NSString stringWithFormat:@"%@", _videoWriter.error]];
    }
    return;
  }
  if (_audioWriterInput.readyForMoreMediaData) {
    if (![_audioWriterInput appendSampleBuffer:sampleBuffer]) {
      [_methodChannel
          invokeMethod:errorMethod
             arguments:[NSString stringWithFormat:@"%@", @"Unable to write to audio input"]];
    }
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
  [_motionManager stopAccelerometerUpdates];
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }

  return pixelBuffer;
}

- (void)startVideoRecordingWithResult:(FlutterResult)result {
  if (!_isRecording) {
    NSError *error;
    _videoRecordingPath = [self getTemporaryFilePathWithExtension:@"mp4"
                                                        subfolder:@"videos"
                                                           prefix:@"REC_"
                                                            error:error];
    if (error) {
      result(getFlutterError(error));
      return;
    }
    if (![self setupWriterForPath:_videoRecordingPath]) {
      result([FlutterError errorWithCode:@"IOError" message:@"Setup Writer Failed" details:nil]);
      return;
    }
    _isRecording = YES;
    _isRecordingPaused = NO;
    _videoTimeOffset = CMTimeMake(0, 1);
    _audioTimeOffset = CMTimeMake(0, 1);
    _videoIsDisconnected = NO;
    _audioIsDisconnected = NO;
    result(nil);
  } else {
    result([FlutterError errorWithCode:@"Error" message:@"Video is already recording" details:nil]);
  }
}

- (void)stopVideoRecordingWithResult:(FlutterResult)result {
  if (_isRecording) {
    _isRecording = NO;

    if (_videoWriter.status != AVAssetWriterStatusUnknown) {
      [_videoWriter finishWritingWithCompletionHandler:^{
        if (self->_videoWriter.status == AVAssetWriterStatusCompleted) {
          [self updateOrientation];
          result(self->_videoRecordingPath);
          self->_videoRecordingPath = nil;
        } else {
          result([FlutterError errorWithCode:@"IOError"
                                     message:@"AVAssetWriter could not finish writing!"
                                     details:nil]);
        }
      }];
    }
  } else {
    NSError *error =
        [NSError errorWithDomain:NSCocoaErrorDomain
                            code:NSURLErrorResourceUnavailable
                        userInfo:@{NSLocalizedDescriptionKey : @"Video is not recording!"}];
    result(getFlutterError(error));
  }
}

- (void)pauseVideoRecordingWithResult:(FlutterResult)result {
  _isRecordingPaused = YES;
  _videoIsDisconnected = YES;
  _audioIsDisconnected = YES;
  result(nil);
}

- (void)resumeVideoRecordingWithResult:(FlutterResult)result {
  _isRecordingPaused = NO;
  result(nil);
}

- (void)lockCaptureOrientationWithResult:(FlutterResult)result
                             orientation:(NSString *)orientationStr {
  UIDeviceOrientation orientation;
  @try {
    orientation = getUIDeviceOrientationForString(orientationStr);
  } @catch (NSError *e) {
    result(getFlutterError(e));
    return;
  }

  if (_lockedCaptureOrientation != orientation) {
    _lockedCaptureOrientation = orientation;
    [self updateOrientation];
  }

  result(nil);
}

- (void)unlockCaptureOrientationWithResult:(FlutterResult)result {
  _lockedCaptureOrientation = UIDeviceOrientationUnknown;
  [self updateOrientation];
  result(nil);
}

- (void)setFlashModeWithResult:(FlutterResult)result mode:(NSString *)modeStr {
  FlashMode mode;
  @try {
    mode = getFlashModeForString(modeStr);
  } @catch (NSError *e) {
    result(getFlutterError(e));
    return;
  }
  if (mode == FlashModeTorch) {
    if (!_captureDevice.hasTorch) {
      result([FlutterError errorWithCode:@"setFlashModeFailed"
                                 message:@"Device does not support torch mode"
                                 details:nil]);
      return;
    }
    if (!_captureDevice.isTorchAvailable) {
      result([FlutterError errorWithCode:@"setFlashModeFailed"
                                 message:@"Torch mode is currently not available"
                                 details:nil]);
      return;
    }
    if (_captureDevice.torchMode != AVCaptureTorchModeOn) {
      [_captureDevice lockForConfiguration:nil];
      [_captureDevice setTorchMode:AVCaptureTorchModeOn];
      [_captureDevice unlockForConfiguration];
    }
  } else {
    if (!_captureDevice.hasFlash) {
      result([FlutterError errorWithCode:@"setFlashModeFailed"
                                 message:@"Device does not have flash capabilities"
                                 details:nil]);
      return;
    }
    AVCaptureFlashMode avFlashMode = getAVCaptureFlashModeForFlashMode(mode);
    if (![_capturePhotoOutput.supportedFlashModes
            containsObject:[NSNumber numberWithInt:((int)avFlashMode)]]) {
      result([FlutterError errorWithCode:@"setFlashModeFailed"
                                 message:@"Device does not support this specific flash mode"
                                 details:nil]);
      return;
    }
    if (_captureDevice.torchMode != AVCaptureTorchModeOff) {
      [_captureDevice lockForConfiguration:nil];
      [_captureDevice setTorchMode:AVCaptureTorchModeOff];
      [_captureDevice unlockForConfiguration];
    }
  }
  _flashMode = mode;
  result(nil);
}

- (void)setExposureModeWithResult:(FlutterResult)result mode:(NSString *)modeStr {
  ExposureMode mode;
  @try {
    mode = getExposureModeForString(modeStr);
  } @catch (NSError *e) {
    result(getFlutterError(e));
    return;
  }
  _exposureMode = mode;
  [self applyExposureMode];
  result(nil);
}

- (void)applyExposureMode {
  [_captureDevice lockForConfiguration:nil];
  switch (_exposureMode) {
    case ExposureModeLocked:
      [_captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      break;
    case ExposureModeAuto:
      if ([_captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [_captureDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
      } else {
        [_captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
      }
      break;
  }
  [_captureDevice unlockForConfiguration];
}

- (void)setFocusModeWithResult:(FlutterResult)result mode:(NSString *)modeStr {
  FocusMode mode;
  @try {
    mode = getFocusModeForString(modeStr);
  } @catch (NSError *e) {
    result(getFlutterError(e));
    return;
  }
  _focusMode = mode;
  [self applyFocusMode];
  result(nil);
}

- (void)applyFocusMode {
  [self applyFocusMode:_focusMode onDevice:_captureDevice];
}

/**
 * Applies FocusMode on the AVCaptureDevice.
 *
 * If the @c focusMode is set to FocusModeAuto the AVCaptureDevice is configured to use
 * AVCaptureFocusModeContinuousModeAutoFocus when supported, otherwise it is set to
 * AVCaptureFocusModeAutoFocus. If neither AVCaptureFocusModeContinuousModeAutoFocus nor
 * AVCaptureFocusModeAutoFocus are supported focus mode will not be set.
 * If @c focusMode is set to FocusModeLocked the AVCaptureDevice is configured to use
 * AVCaptureFocusModeAutoFocus. If AVCaptureFocusModeAutoFocus is not supported focus mode will not
 * be set.
 *
 * @param focusMode The focus mode that should be applied to the @captureDevice instance.
 * @param captureDevice The AVCaptureDevice to which the @focusMode will be applied.
 */
- (void)applyFocusMode:(FocusMode)focusMode onDevice:(AVCaptureDevice *)captureDevice {
  [captureDevice lockForConfiguration:nil];
  switch (focusMode) {
    case FocusModeLocked:
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
      break;
    case FocusModeAuto:
      if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
      } else if ([captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
      }
      break;
  }
  [captureDevice unlockForConfiguration];
}

- (void)pausePreviewWithResult:(FlutterResult)result {
  _isPreviewPaused = true;
  result(nil);
}

- (void)resumePreviewWithResult:(FlutterResult)result {
  _isPreviewPaused = false;
  result(nil);
}

- (CGPoint)getCGPointForCoordsWithOrientation:(UIDeviceOrientation)orientation
                                            x:(double)x
                                            y:(double)y {
  double oldX = x, oldY = y;
  switch (orientation) {
    case UIDeviceOrientationPortrait:  // 90 ccw
      y = 1 - oldX;
      x = oldY;
      break;
    case UIDeviceOrientationPortraitUpsideDown:  // 90 cw
      x = 1 - oldY;
      y = oldX;
      break;
    case UIDeviceOrientationLandscapeRight:  // 180
      x = 1 - x;
      y = 1 - y;
      break;
    case UIDeviceOrientationLandscapeLeft:
    default:
      // No rotation required
      break;
  }
  return CGPointMake(x, y);
}

- (void)setExposurePointWithResult:(FlutterResult)result x:(double)x y:(double)y {
  if (!_captureDevice.isExposurePointOfInterestSupported) {
    result([FlutterError errorWithCode:@"setExposurePointFailed"
                               message:@"Device does not have exposure point capabilities"
                               details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [_captureDevice lockForConfiguration:nil];
  [_captureDevice setExposurePointOfInterest:[self getCGPointForCoordsWithOrientation:orientation
                                                                                    x:x
                                                                                    y:y]];
  [_captureDevice unlockForConfiguration];
  // Retrigger auto exposure
  [self applyExposureMode];
  result(nil);
}

- (void)setFocusPointWithResult:(FlutterResult)result x:(double)x y:(double)y {
  if (!_captureDevice.isFocusPointOfInterestSupported) {
    result([FlutterError errorWithCode:@"setFocusPointFailed"
                               message:@"Device does not have focus point capabilities"
                               details:nil]);
    return;
  }
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  [_captureDevice lockForConfiguration:nil];

  [_captureDevice setFocusPointOfInterest:[self getCGPointForCoordsWithOrientation:orientation
                                                                                 x:x
                                                                                 y:y]];
  [_captureDevice unlockForConfiguration];
  // Retrigger auto focus
  [self applyFocusMode];

  result(nil);
}

- (void)setExposureOffsetWithResult:(FlutterResult)result offset:(double)offset {
  [_captureDevice lockForConfiguration:nil];
  [_captureDevice setExposureTargetBias:offset completionHandler:nil];
  [_captureDevice unlockForConfiguration];
  result(@(offset));
}

- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  if (!_isStreamingImages) {
    FlutterEventChannel *eventChannel =
        [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/camera/imageStream"
                                  binaryMessenger:messenger];

    _imageStreamHandler = [[FLTImageStreamHandler alloc] init];
    [eventChannel setStreamHandler:_imageStreamHandler];

    _isStreamingImages = YES;
  } else {
    [_methodChannel invokeMethod:errorMethod
                       arguments:@"Images from camera are already streaming!"];
  }
}

- (void)stopImageStream {
  if (_isStreamingImages) {
    _isStreamingImages = NO;
    _imageStreamHandler = nil;
  } else {
    [_methodChannel invokeMethod:errorMethod arguments:@"Images from camera are not streaming!"];
  }
}

- (void)getMaxZoomLevelWithResult:(FlutterResult)result {
  CGFloat maxZoomFactor = [self getMaxAvailableZoomFactor];

  result([NSNumber numberWithFloat:maxZoomFactor]);
}

- (void)getMinZoomLevelWithResult:(FlutterResult)result {
  CGFloat minZoomFactor = [self getMinAvailableZoomFactor];

  result([NSNumber numberWithFloat:minZoomFactor]);
}

- (void)setZoomLevel:(CGFloat)zoom Result:(FlutterResult)result {
  CGFloat maxAvailableZoomFactor = [self getMaxAvailableZoomFactor];
  CGFloat minAvailableZoomFactor = [self getMinAvailableZoomFactor];

  if (maxAvailableZoomFactor < zoom || minAvailableZoomFactor > zoom) {
    NSString *errorMessage = [NSString
        stringWithFormat:@"Zoom level out of bounds (zoom level should be between %f and %f).",
                         minAvailableZoomFactor, maxAvailableZoomFactor];
    FlutterError *error = [FlutterError errorWithCode:@"ZOOM_ERROR"
                                              message:errorMessage
                                              details:nil];
    result(error);
    return;
  }

  NSError *error = nil;
  if (![_captureDevice lockForConfiguration:&error]) {
    result(getFlutterError(error));
    return;
  }
  _captureDevice.videoZoomFactor = zoom;
  [_captureDevice unlockForConfiguration];

  result(nil);
}

- (CGFloat)getMinAvailableZoomFactor {
  if (@available(iOS 11.0, *)) {
    return _captureDevice.minAvailableVideoZoomFactor;
  } else {
    return 1.0;
  }
}

- (CGFloat)getMaxAvailableZoomFactor {
  if (@available(iOS 11.0, *)) {
    return _captureDevice.maxAvailableVideoZoomFactor;
  } else {
    return _captureDevice.activeFormat.videoMaxZoomFactor;
  }
}

- (BOOL)setupWriterForPath:(NSString *)path {
  NSError *error = nil;
  NSURL *outputURL;
  if (path != nil) {
    outputURL = [NSURL fileURLWithPath:path];
  } else {
    return NO;
  }
  if (_enableAudio && !_isAudioSetup) {
    [self setUpCaptureSessionForAudio];
  }

  _videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL
                                           fileType:AVFileTypeMPEG4
                                              error:&error];
  NSParameterAssert(_videoWriter);
  if (error) {
    [_methodChannel invokeMethod:errorMethod arguments:error.description];
    return NO;
  }

  NSDictionary *videoSettings = [_captureVideoOutput
      recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
  _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                         outputSettings:videoSettings];

  _videoAdaptor = [AVAssetWriterInputPixelBufferAdaptor
      assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                                 sourcePixelBufferAttributes:@{
                                   (NSString *)kCVPixelBufferPixelFormatTypeKey : @(videoFormat)
                                 }];

  NSParameterAssert(_videoWriterInput);

  _videoWriterInput.expectsMediaDataInRealTime = YES;

  // Add the audio input
  if (_enableAudio) {
    AudioChannelLayout acl;
    bzero(&acl, sizeof(acl));
    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    NSDictionary *audioOutputSettings = nil;
    // Both type of audio inputs causes output video file to be corrupted.
    audioOutputSettings = @{
      AVFormatIDKey : [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
      AVSampleRateKey : [NSNumber numberWithFloat:44100.0],
      AVNumberOfChannelsKey : [NSNumber numberWithInt:1],
      AVChannelLayoutKey : [NSData dataWithBytes:&acl length:sizeof(acl)],
    };
    _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                           outputSettings:audioOutputSettings];
    _audioWriterInput.expectsMediaDataInRealTime = YES;

    [_videoWriter addInput:_audioWriterInput];
    [_audioOutput setSampleBufferDelegate:self queue:_dispatchQueue];
  }

  if (_flashMode == FlashModeTorch) {
    [self.captureDevice lockForConfiguration:nil];
    [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
    [self.captureDevice unlockForConfiguration];
  }

  [_videoWriter addInput:_videoWriterInput];

  [_captureVideoOutput setSampleBufferDelegate:self queue:_dispatchQueue];

  return YES;
}

- (void)setUpCaptureSessionForAudio {
  NSError *error = nil;
  // Create a device input with the device and add it to the session.
  // Setup the audio input.
  AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
  AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice
                                                                           error:&error];
  if (error) {
    [_methodChannel invokeMethod:errorMethod arguments:error.description];
  }
  // Setup the audio output.
  _audioOutput = [[AVCaptureAudioDataOutput alloc] init];

  if ([_captureSession canAddInput:audioInput]) {
    [_captureSession addInput:audioInput];

    if ([_captureSession canAddOutput:_audioOutput]) {
      [_captureSession addOutput:_audioOutput];
      _isAudioSetup = YES;
    } else {
      [_methodChannel invokeMethod:errorMethod
                         arguments:@"Unable to add Audio input/output to session capture"];
      _isAudioSetup = NO;
    }
  }
}
@end

@interface CameraPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) FLTCam *camera;
@property(readonly, nonatomic) FlutterMethodChannel *deviceEventMethodChannel;
@end

@implementation CameraPlugin {
  dispatch_queue_t _dispatchQueue;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/camera"
                                  binaryMessenger:[registrar messenger]];
  CameraPlugin *instance = [[CameraPlugin alloc] initWithRegistry:[registrar textures]
                                                        messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _messenger = messenger;
  [self initDeviceEventMethodChannel];
  [self startOrientationListener];
  return self;
}

- (void)initDeviceEventMethodChannel {
  _deviceEventMethodChannel =
      [FlutterMethodChannel methodChannelWithName:@"flutter.io/cameraPlugin/device"
                                  binaryMessenger:_messenger];
}

- (void)startOrientationListener {
  [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(orientationChanged:)
                                               name:UIDeviceOrientationDidChangeNotification
                                             object:[UIDevice currentDevice]];
}

- (void)orientationChanged:(NSNotification *)note {
  UIDevice *device = note.object;
  UIDeviceOrientation orientation = device.orientation;

  if (orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown) {
    // Do not change when oriented flat.
    return;
  }

  if (_camera) {
    [_camera setDeviceOrientation:orientation];
  }

  [self sendDeviceOrientation:orientation];
}

- (void)sendDeviceOrientation:(UIDeviceOrientation)orientation {
  [_deviceEventMethodChannel
      invokeMethod:@"orientation_changed"
         arguments:@{@"orientation" : getStringForUIDeviceOrientation(orientation)}];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if (_dispatchQueue == nil) {
    _dispatchQueue = dispatch_queue_create("io.flutter.camera.dispatchqueue", NULL);
  }

  // Invoke the plugin on another dispatch queue to avoid blocking the UI.
  dispatch_async(_dispatchQueue, ^{
    [self handleMethodCallAsync:call result:result];
  });
}

- (void)handleMethodCallAsync:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"availableCameras" isEqualToString:call.method]) {
    if (@available(iOS 10.0, *)) {
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
          @"sensorOrientation" : @90,
        }];
      }
      result(reply);
    } else {
      result(FlutterMethodNotImplemented);
    }
  } else if ([@"create" isEqualToString:call.method]) {
    NSString *cameraName = call.arguments[@"cameraName"];
    NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
    NSNumber *enableAudio = call.arguments[@"enableAudio"];
    NSError *error;
    FLTCam *cam = [[FLTCam alloc] initWithCameraName:cameraName
                                    resolutionPreset:resolutionPreset
                                         enableAudio:[enableAudio boolValue]
                                         orientation:[[UIDevice currentDevice] orientation]
                                       dispatchQueue:_dispatchQueue
                                               error:&error];

    if (error) {
      result(getFlutterError(error));
    } else {
      if (_camera) {
        [_camera close];
      }
      int64_t textureId = [_registry registerTexture:cam];
      _camera = cam;

      result(@{
        @"cameraId" : @(textureId),
      });
    }
  } else if ([@"startImageStream" isEqualToString:call.method]) {
    [_camera startImageStreamWithMessenger:_messenger];
    result(nil);
  } else if ([@"stopImageStream" isEqualToString:call.method]) {
    [_camera stopImageStream];
    result(nil);
  } else {
    NSDictionary *argsMap = call.arguments;
    NSUInteger cameraId = ((NSNumber *)argsMap[@"cameraId"]).unsignedIntegerValue;
    if ([@"initialize" isEqualToString:call.method]) {
      NSString *videoFormatValue = ((NSString *)argsMap[@"imageFormatGroup"]);
      videoFormat = getVideoFormatFromString(videoFormatValue);

      __weak CameraPlugin *weakSelf = self;
      _camera.onFrameAvailable = ^{
        if (![weakSelf.camera isPreviewPaused]) {
          [weakSelf.registry textureFrameAvailable:cameraId];
        }
      };
      FlutterMethodChannel *methodChannel = [FlutterMethodChannel
          methodChannelWithName:[NSString stringWithFormat:@"flutter.io/cameraPlugin/camera%lu",
                                                           (unsigned long)cameraId]
                binaryMessenger:_messenger];
      _camera.methodChannel = methodChannel;
      [methodChannel
          invokeMethod:@"initialized"
             arguments:@{
               @"previewWidth" : @(_camera.previewSize.width),
               @"previewHeight" : @(_camera.previewSize.height),
               @"exposureMode" : getStringForExposureMode([_camera exposureMode]),
               @"focusMode" : getStringForFocusMode([_camera focusMode]),
               @"exposurePointSupported" :
                   @([_camera.captureDevice isExposurePointOfInterestSupported]),
               @"focusPointSupported" : @([_camera.captureDevice isFocusPointOfInterestSupported]),
             }];
      [self sendDeviceOrientation:[UIDevice currentDevice].orientation];
      [_camera start];
      result(nil);
    } else if ([@"takePicture" isEqualToString:call.method]) {
      if (@available(iOS 10.0, *)) {
        [_camera captureToFile:result];
      } else {
        result(FlutterMethodNotImplemented);
      }
    } else if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:cameraId];
      [_camera close];
      _dispatchQueue = nil;
      result(nil);
    } else if ([@"prepareForVideoRecording" isEqualToString:call.method]) {
      [_camera setUpCaptureSessionForAudio];
      result(nil);
    } else if ([@"startVideoRecording" isEqualToString:call.method]) {
      [_camera startVideoRecordingWithResult:result];
    } else if ([@"stopVideoRecording" isEqualToString:call.method]) {
      [_camera stopVideoRecordingWithResult:result];
    } else if ([@"pauseVideoRecording" isEqualToString:call.method]) {
      [_camera pauseVideoRecordingWithResult:result];
    } else if ([@"resumeVideoRecording" isEqualToString:call.method]) {
      [_camera resumeVideoRecordingWithResult:result];
    } else if ([@"getMaxZoomLevel" isEqualToString:call.method]) {
      [_camera getMaxZoomLevelWithResult:result];
    } else if ([@"getMinZoomLevel" isEqualToString:call.method]) {
      [_camera getMinZoomLevelWithResult:result];
    } else if ([@"setZoomLevel" isEqualToString:call.method]) {
      CGFloat zoom = ((NSNumber *)argsMap[@"zoom"]).floatValue;
      [_camera setZoomLevel:zoom Result:result];
    } else if ([@"setFlashMode" isEqualToString:call.method]) {
      [_camera setFlashModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setExposureMode" isEqualToString:call.method]) {
      [_camera setExposureModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setExposurePoint" isEqualToString:call.method]) {
      BOOL reset = ((NSNumber *)call.arguments[@"reset"]).boolValue;
      double x = 0.5;
      double y = 0.5;
      if (!reset) {
        x = ((NSNumber *)call.arguments[@"x"]).doubleValue;
        y = ((NSNumber *)call.arguments[@"y"]).doubleValue;
      }
      [_camera setExposurePointWithResult:result x:x y:y];
    } else if ([@"getMinExposureOffset" isEqualToString:call.method]) {
      result(@(_camera.captureDevice.minExposureTargetBias));
    } else if ([@"getMaxExposureOffset" isEqualToString:call.method]) {
      result(@(_camera.captureDevice.maxExposureTargetBias));
    } else if ([@"getExposureOffsetStepSize" isEqualToString:call.method]) {
      result(@(0.0));
    } else if ([@"setExposureOffset" isEqualToString:call.method]) {
      [_camera setExposureOffsetWithResult:result
                                    offset:((NSNumber *)call.arguments[@"offset"]).doubleValue];
    } else if ([@"lockCaptureOrientation" isEqualToString:call.method]) {
      [_camera lockCaptureOrientationWithResult:result orientation:call.arguments[@"orientation"]];
    } else if ([@"unlockCaptureOrientation" isEqualToString:call.method]) {
      [_camera unlockCaptureOrientationWithResult:result];
    } else if ([@"setFocusMode" isEqualToString:call.method]) {
      [_camera setFocusModeWithResult:result mode:call.arguments[@"mode"]];
    } else if ([@"setFocusPoint" isEqualToString:call.method]) {
      BOOL reset = ((NSNumber *)call.arguments[@"reset"]).boolValue;
      double x = 0.5;
      double y = 0.5;
      if (!reset) {
        x = ((NSNumber *)call.arguments[@"x"]).doubleValue;
        y = ((NSNumber *)call.arguments[@"y"]).doubleValue;
      }
      [_camera setFocusPointWithResult:result x:x y:y];
    } else if ([@"pausePreview" isEqualToString:call.method]) {
      [_camera pausePreviewWithResult:result];
    } else if ([@"resumePreview" isEqualToString:call.method]) {
      [_camera resumePreviewWithResult:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

@end
