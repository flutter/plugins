#import "CameraPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <CoreMotion/CoreMotion.h>
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

@interface FLTSavePhotoDelegate : NSObject <AVCapturePhotoCaptureDelegate>
@property(readonly, nonatomic) NSString *path;
@property(readonly, nonatomic) FlutterResult result;
@property(readonly, nonatomic) CMMotionManager *motionManager;
@property(readonly, nonatomic) AVCaptureDevicePosition cameraPosition;

- initWithPath:(NSString *)filename
            result:(FlutterResult)result
     motionManager:(CMMotionManager *)motionManager
    cameraPosition:(AVCaptureDevicePosition)cameraPosition;
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

- initWithPath:(NSString *)path
            result:(FlutterResult)result
     motionManager:(CMMotionManager *)motionManager
    cameraPosition:(AVCaptureDevicePosition)cameraPosition {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _path = path;
  _result = result;
  _motionManager = motionManager;
  _cameraPosition = cameraPosition;
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
  UIImage *image = [UIImage imageWithCGImage:[UIImage imageWithData:data].CGImage
                                       scale:1.0
                                 orientation:[self getImageRotation]];
  // TODO(sigurdm): Consider writing file asynchronously.
  bool success = [UIImageJPEGRepresentation(image, 1.0) writeToFile:_path atomically:YES];
  if (!success) {
    _result([FlutterError errorWithCode:@"IOError" message:@"Unable to write file" details:nil]);
    return;
  }
  _result(nil);
}

- (UIImageOrientation)getImageRotation {
  // Get the true device orientation out of the accelerometer.
  const CMQuaternion orientation = _motionManager.deviceMotion.attitude.quaternion;
  const double roll =
      atan2(2 * (orientation.w * orientation.x + orientation.y * orientation.z),
            1 - (2 * (orientation.x * orientation.x + orientation.y * orientation.y)));
  const double pitch = asin(2 * (orientation.w * orientation.y - orientation.z * orientation.x));
  const bool vertical = fabs(pitch) <= M_PI_4;
  const bool pointedRight = pitch >= 0;
  const bool tiltedUp = roll >= 0;
  // Pixel input defaults to horizontal pointed left, as if the phone was held
  // with the home button on the right. Rotate the photo accordingly based on
  // the orientation the photo should really be displayed as. To make this
  // extra confusing, the landscape orientations also need to be mirrored
  // based on whether they were taken with the front facing camera.
  if (vertical && tiltedUp) {              // [^]
    return UIImageOrientationRight;        // rotate existing image 90* cw
  } else if (vertical && !tiltedUp) {      // [v]
    return UIImageOrientationLeft;         // rotate existing image 90* ccw
  } else if (!vertical && pointedRight) {  // [>]
    return _cameraPosition == AVCaptureDevicePositionBack ? UIImageOrientationDown /*rotate 180* */
                                                          : UIImageOrientationUp /*do not rotate*/;
  } else if (!vertical && !pointedRight) {  // [<]
    return _cameraPosition == AVCaptureDevicePositionBack ? UIImageOrientationUp
                                                          : UIImageOrientationDown;
  }
  return UIImageOrientationUp;
}
@end

@interface FLTCam : NSObject <FlutterTexture,
                              AVCaptureVideoDataOutputSampleBufferDelegate,
                              AVCaptureAudioDataOutputSampleBufferDelegate,
                              FlutterStreamHandler>
@property(readonly, nonatomic) int64_t textureId;
@property(nonatomic, copy) void (^onFrameAvailable)();
@property(nonatomic) FlutterEventChannel *eventChannel;
@property(nonatomic) FLTImageStreamHandler *imageStreamHandler;
@property(nonatomic) FlutterEventSink eventSink;
@property(readonly, nonatomic) AVCaptureSession *captureSession;
@property(readonly, nonatomic) AVCaptureDevice *captureDevice;
@property(readonly, nonatomic) AVCapturePhotoOutput *capturePhotoOutput;
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
@property(assign, nonatomic) BOOL isRecording;
@property(assign, nonatomic) BOOL isAudioSetup;
@property(assign, nonatomic) BOOL isStreamingImages;
@property(nonatomic) vImage_Buffer destinationBuffer;
@property(nonatomic) vImage_Buffer conversionBuffer;
@property(nonatomic) CMMotionManager *motionManager;
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error;

- (void)start;
- (void)stop;
- (void)startVideoRecordingAtPath:(NSString *)path result:(FlutterResult)result;
- (void)stopVideoRecordingWithResult:(FlutterResult)result;
- (void)startImageStreamWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger;
- (void)stopImageStream;
- (void)captureToFile:(NSString *)filename result:(FlutterResult)result;
@end

@implementation FLTCam
// Yuv420 format used for iOS 10+, which is minimum requirement for this plugin.
// Format is used to stream image byte data to dart.
FourCharCode const videoFormat = kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;

- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _captureSession = [[AVCaptureSession alloc] init];
  AVCaptureSessionPreset preset;
  if ([resolutionPreset isEqualToString:@"high"]) {
    preset = AVCaptureSessionPreset1280x720;
    _previewSize = CGSizeMake(1280, 720);
  } else if ([resolutionPreset isEqualToString:@"medium"]) {
    preset = AVCaptureSessionPreset640x480;
    _previewSize = CGSizeMake(640, 480);
  } else {
    NSAssert([resolutionPreset isEqualToString:@"low"], @"Unknown resolution preset %@",
             resolutionPreset);
    preset = AVCaptureSessionPreset352x288;
    _previewSize = CGSizeMake(352, 288);
  }
  _captureSession.sessionPreset = preset;
  _captureDevice = [AVCaptureDevice deviceWithUniqueID:cameraName];
  NSError *localError = nil;
  _captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice
                                                             error:&localError];
  if (localError) {
    *error = localError;
    return nil;
  }

  vImageBuffer_Init(&_destinationBuffer, _previewSize.width, _previewSize.height, 32,
                    kvImageNoFlags);
  vImageBuffer_Init(&_conversionBuffer, _previewSize.width, _previewSize.height, 32,
                    kvImageNoFlags);

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
  connection.videoOrientation = AVCaptureVideoOrientationPortrait;
  [_captureSession addInputWithNoConnections:_captureVideoInput];
  [_captureSession addOutputWithNoConnections:_captureVideoOutput];
  [_captureSession addConnection:connection];
  _capturePhotoOutput = [AVCapturePhotoOutput new];
  [_capturePhotoOutput setHighResolutionCaptureEnabled:YES];
  [_captureSession addOutput:_capturePhotoOutput];
  _motionManager = [[CMMotionManager alloc] init];
  [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:
                      CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
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
  [settings setHighResolutionPhotoEnabled:YES];
  [_capturePhotoOutput
      capturePhotoWithSettings:settings
                      delegate:[[FLTSavePhotoDelegate alloc] initWithPath:path
                                                                   result:result
                                                            motionManager:_motionManager
                                                           cameraPosition:_captureDevice.position]];
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
    _eventSink(@{
      @"event" : @"error",
      @"errorDescription" : @"sample buffer is not ready. Skipping sample"
    });
    return;
  }
  if (_isStreamingImages) {
    if (_imageStreamHandler.eventSink) {
      CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
      CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

      size_t imageWidth = CVPixelBufferGetWidth(pixelBuffer);
      size_t imageHeight = CVPixelBufferGetHeight(pixelBuffer);

      NSMutableArray *planes = [NSMutableArray array];

      size_t planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
      for (int i = 0; i < planeCount; i++) {
        void *planeAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, i);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, i);
        size_t height = CVPixelBufferGetHeightOfPlane(pixelBuffer, i);
        size_t width = CVPixelBufferGetWidthOfPlane(pixelBuffer, i);

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

      _imageStreamHandler.eventSink(imageBuffer);

      CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
    }
  }
  if (_isRecording) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" : [NSString stringWithFormat:@"%@", _videoWriter.error]
      });
      return;
    }
    CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (_videoWriter.status != AVAssetWriterStatusWriting) {
      [_videoWriter startWriting];
      [_videoWriter startSessionAtSourceTime:lastSampleTime];
    }
    if (output == _captureVideoOutput) {
      [self newVideoSample:sampleBuffer];
    } else {
      [self newAudioSample:sampleBuffer];
    }
  }
}

- (void)newVideoSample:(CMSampleBufferRef)sampleBuffer {
  if (_videoWriter.status != AVAssetWriterStatusWriting) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" : [NSString stringWithFormat:@"%@", _videoWriter.error]
      });
    }
    return;
  }
  if (_videoWriterInput.readyForMoreMediaData) {
    if (![_videoWriterInput appendSampleBuffer:sampleBuffer]) {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" :
            [NSString stringWithFormat:@"%@", @"Unable to write to video input"]
      });
    }
  }
}

- (void)newAudioSample:(CMSampleBufferRef)sampleBuffer {
  if (_videoWriter.status != AVAssetWriterStatusWriting) {
    if (_videoWriter.status == AVAssetWriterStatusFailed) {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" : [NSString stringWithFormat:@"%@", _videoWriter.error]
      });
    }
    return;
  }
  if (_audioWriterInput.readyForMoreMediaData) {
    if (![_audioWriterInput appendSampleBuffer:sampleBuffer]) {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" :
            [NSString stringWithFormat:@"%@", @"Unable to write to audio input"]
      });
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
  [_motionManager stopDeviceMotionUpdates];
}

- (CVPixelBufferRef)copyPixelBuffer {
  CVPixelBufferRef pixelBuffer = _latestPixelBuffer;
  while (!OSAtomicCompareAndSwapPtrBarrier(pixelBuffer, nil, (void **)&_latestPixelBuffer)) {
    pixelBuffer = _latestPixelBuffer;
  }

  return [self convertYUVImageToBGRA:pixelBuffer];
}

// Since video format was changed to kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange we have to
// convert image to a usable format for flutter textures. Which is kCVPixelFormatType_32BGRA.
- (CVPixelBufferRef)convertYUVImageToBGRA:(CVPixelBufferRef)pixelBuffer {
  CVPixelBufferLockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);

  vImage_YpCbCrToARGB infoYpCbCrToARGB;
  vImage_YpCbCrPixelRange pixelRange;
  pixelRange.Yp_bias = 16;
  pixelRange.CbCr_bias = 128;
  pixelRange.YpRangeMax = 235;
  pixelRange.CbCrRangeMax = 240;
  pixelRange.YpMax = 235;
  pixelRange.YpMin = 16;
  pixelRange.CbCrMax = 240;
  pixelRange.CbCrMin = 16;

  vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange,
                                                &infoYpCbCrToARGB, kvImage420Yp8_CbCr8,
                                                kvImageARGB8888, kvImageNoFlags);

  vImage_Buffer sourceLumaBuffer;
  sourceLumaBuffer.data = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
  sourceLumaBuffer.rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);

  vImage_Buffer sourceChromaBuffer;
  sourceChromaBuffer.data = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.height = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.width = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
  sourceChromaBuffer.rowBytes = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);

  vImageConvert_420Yp8_CbCr8ToARGB8888(&sourceLumaBuffer, &sourceChromaBuffer, &_destinationBuffer,
                                       &infoYpCbCrToARGB, NULL, 255,
                                       kvImagePrintDiagnosticsToConsole);

  CVPixelBufferUnlockBaseAddress(pixelBuffer, kCVPixelBufferLock_ReadOnly);
  CVPixelBufferRelease(pixelBuffer);

  const uint8_t map[4] = {3, 2, 1, 0};
  vImagePermuteChannels_ARGB8888(&_destinationBuffer, &_conversionBuffer, map, kvImageNoFlags);

  CVPixelBufferRef newPixelBuffer = NULL;
  CVPixelBufferCreateWithBytes(NULL, _conversionBuffer.width, _conversionBuffer.height,
                               kCVPixelFormatType_32BGRA, _conversionBuffer.data,
                               _conversionBuffer.rowBytes, NULL, NULL, NULL, &newPixelBuffer);

  return newPixelBuffer;
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

- (void)startVideoRecordingAtPath:(NSString *)path result:(FlutterResult)result {
  if (!_isRecording) {
    if (![self setupWriterForPath:path]) {
      _eventSink(@{@"event" : @"error", @"errorDescription" : @"Setup Writer Failed"});
      return;
    }
    [_captureSession stopRunning];
    _isRecording = YES;
    [_captureSession startRunning];
    result(nil);
  } else {
    _eventSink(@{@"event" : @"error", @"errorDescription" : @"Video is already recording!"});
  }
}

- (void)stopVideoRecordingWithResult:(FlutterResult)result {
  if (_isRecording) {
    _isRecording = NO;
    if (_videoWriter.status != AVAssetWriterStatusUnknown) {
      [_videoWriter finishWritingWithCompletionHandler:^{
        if (self->_videoWriter.status == AVAssetWriterStatusCompleted) {
          result(nil);
        } else {
          self->_eventSink(@{
            @"event" : @"error",
            @"errorDescription" : @"AVAssetWriter could not finish writing!"
          });
        }
      }];
    }
  } else {
    NSError *error =
        [NSError errorWithDomain:NSCocoaErrorDomain
                            code:NSURLErrorResourceUnavailable
                        userInfo:@{NSLocalizedDescriptionKey : @"Video is not recording!"}];
    result([error flutterError]);
  }
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
    _eventSink(
        @{@"event" : @"error", @"errorDescription" : @"Images from camera are already streaming!"});
  }
}

- (void)stopImageStream {
  if (_isStreamingImages) {
    _isStreamingImages = NO;
    _imageStreamHandler = nil;
  } else {
    _eventSink(
        @{@"event" : @"error", @"errorDescription" : @"Images from camera are not streaming!"});
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
  if (!_isAudioSetup) {
    [self setUpCaptureSessionForAudio];
  }
  _videoWriter = [[AVAssetWriter alloc] initWithURL:outputURL
                                           fileType:AVFileTypeQuickTimeMovie
                                              error:&error];
  NSParameterAssert(_videoWriter);
  if (error) {
    _eventSink(@{@"event" : @"error", @"errorDescription" : error.description});
    return NO;
  }
  NSDictionary *videoSettings = [NSDictionary
      dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:_previewSize.height], AVVideoWidthKey,
                                   [NSNumber numberWithInt:_previewSize.width], AVVideoHeightKey,
                                   nil];
  _videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                         outputSettings:videoSettings];
  NSParameterAssert(_videoWriterInput);
  _videoWriterInput.expectsMediaDataInRealTime = YES;

  // Add the audio input
  AudioChannelLayout acl;
  bzero(&acl, sizeof(acl));
  acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
  NSDictionary *audioOutputSettings = nil;
  // Both type of audio inputs causes output video file to be corrupted.
  audioOutputSettings = [NSDictionary
      dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                   [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                   [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                   [NSData dataWithBytes:&acl length:sizeof(acl)],
                                   AVChannelLayoutKey, nil];
  _audioWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                         outputSettings:audioOutputSettings];
  _audioWriterInput.expectsMediaDataInRealTime = YES;
  [_videoWriter addInput:_videoWriterInput];
  [_videoWriter addInput:_audioWriterInput];
  dispatch_queue_t queue = dispatch_queue_create("MyQueue", NULL);
  [_captureVideoOutput setSampleBufferDelegate:self queue:queue];
  [_audioOutput setSampleBufferDelegate:self queue:queue];

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
    _eventSink(@{@"event" : @"error", @"errorDescription" : error.description});
  }
  // Setup the audio output.
  _audioOutput = [[AVCaptureAudioDataOutput alloc] init];

  if ([_captureSession canAddInput:audioInput]) {
    [_captureSession addInput:audioInput];

    if ([_captureSession canAddOutput:_audioOutput]) {
      [_captureSession addOutput:_audioOutput];
      _isAudioSetup = YES;
    } else {
      _eventSink(@{
        @"event" : @"error",
        @"errorDescription" : @"Unable to add Audio input/output to session capture"
      });
      _isAudioSetup = NO;
    }
  }
}
@end

@interface CameraPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation CameraPlugin
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
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    if (_camera) {
      [_camera close];
    }
    result(nil);
  } else if ([@"availableCameras" isEqualToString:call.method]) {
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
  } else if ([@"initialize" isEqualToString:call.method]) {
    NSString *cameraName = call.arguments[@"cameraName"];
    NSString *resolutionPreset = call.arguments[@"resolutionPreset"];
    NSError *error;
    FLTCam *cam = [[FLTCam alloc] initWithCameraName:cameraName
                                    resolutionPreset:resolutionPreset
                                               error:&error];
    if (error) {
      result([error flutterError]);
    } else {
      if (_camera) {
        [_camera close];
      }
      int64_t textureId = [_registry registerTexture:cam];
      _camera = cam;
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
      [cam start];
    }
  } else if ([@"startImageStream" isEqualToString:call.method]) {
    [_camera startImageStreamWithMessenger:_messenger];
    result(nil);
  } else if ([@"stopImageStream" isEqualToString:call.method]) {
    [_camera stopImageStream];
    result(nil);
  } else {
    NSDictionary *argsMap = call.arguments;
    NSUInteger textureId = ((NSNumber *)argsMap[@"textureId"]).unsignedIntegerValue;

    if ([@"takePicture" isEqualToString:call.method]) {
      [_camera captureToFile:call.arguments[@"path"] result:result];
    } else if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:textureId];
      [_camera close];
      result(nil);
    } else if ([@"startVideoRecording" isEqualToString:call.method]) {
      [_camera startVideoRecordingAtPath:call.arguments[@"filePath"] result:result];
    } else if ([@"stopVideoRecording" isEqualToString:call.method]) {
      [_camera stopVideoRecordingWithResult:result];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

@end
