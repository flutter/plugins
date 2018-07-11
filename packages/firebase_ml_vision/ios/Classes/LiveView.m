#import "FirebaseMlVisionPlugin.h"
#import "LiveView.h"
#import "UIUtilities.h"
#import <AVFoundation/AVFoundation.h>
#import <libkern/OSAtomic.h>

@interface FLTCam ()
@property (assign, atomic) BOOL isRecognizing;
@end

@implementation FLTCam
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _isUsingFrontCamera = NO;
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
  _captureVideoInput =
  [AVCaptureDeviceInput deviceInputWithDevice:_captureDevice error:&localError];
  if (localError) {
    *error = localError;
    return nil;
  }
  CMVideoDimensions dimensions =
  CMVideoFormatDescriptionGetDimensions([[_captureDevice activeFormat] formatDescription]);
  _previewSize = CGSizeMake(dimensions.width, dimensions.height);
  
  _captureVideoOutput = [AVCaptureVideoDataOutput new];
  _captureVideoOutput.videoSettings =
  @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
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
//  AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
//  [_capturePhotoOutput
//   capturePhotoWithSettings:settings
//   delegate:[[FLTSavePhotoDelegate alloc] initWithPath:path result:result]];
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
    if (!_isRecognizing) {
      _isRecognizing = YES;
      FIRVisionImage *visionImage = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
      FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
      UIImageOrientation orientation = [UIUtilities imageOrientationFromDevicePosition:_isUsingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack];
      FIRVisionDetectorImageOrientation visionOrientation = [UIUtilities visionImageOrientationFromImageOrientation:orientation];
      
      metadata.orientation = visionOrientation;
      visionImage.metadata = metadata;
      CGFloat imageWidth = CVPixelBufferGetWidth(newBuffer);
      CGFloat imageHeight = CVPixelBufferGetHeight(newBuffer);
      [BarcodeDetector handleDetection:visionImage result:_eventSink resultWrapper:^id(id  _Nullable result) {
        _isRecognizing = NO;
        return @{@"eventType": @"recognized", @"recognitionType": @"barcode", @"barcodeData": result};
      }];
    }
//    switch (_currentDetector) {
//      case DetectorOnDeviceFace:
//        [self detectFacesOnDeviceInImage:visionImage width:imageWidth height:imageHeight];
//        break;
//      case DetectorOnDeviceText:
//        [self detectTextOnDeviceInImage:visionImage width:imageWidth height:imageHeight];
//        break;
//    }
  }
  if (!CMSampleBufferDataIsReady(sampleBuffer)) {
    _eventSink(@{
                 @"event" : @"error",
                 @"errorDescription" : @"sample buffer is not ready. Skipping sample"
                 });
    return;
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
//    NSError *error =
//    [NSError errorWithDomain:NSCocoaErrorDomain
//                        code:NSURLErrorResourceUnavailable
//                    userInfo:@{NSLocalizedDescriptionKey : @"Video is not recording!"}];
//    result([error flutterError]);
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
  _videoWriter =
  [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
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
  AVCaptureDeviceInput *audioInput =
  [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
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
