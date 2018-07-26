#import "LiveView.h"
#import <AVFoundation/AVFoundation.h>
#import <libkern/OSAtomic.h>
#import "FirebaseMlVisionPlugin.h"
#import "NSError+FlutterError.h"
#import "UIUtilities.h"

static NSString *const sessionQueueLabel =
    @"io.flutter.plugins.firebaseml.visiondetector.SessionQueue";
static NSString *const videoDataOutputQueueLabel =
    @"io.flutter.plugins.firebaseml.visiondetector.VideoDataOutputQueue";

@interface LiveView ()
@property(assign, atomic) BOOL isRecognizing;
@property(nonatomic) dispatch_queue_t sessionQueue;
@property(strong, nonatomic) NSObject<Detector> *currentDetector;
@property(strong, nonatomic) NSDictionary *currentDetectorOptions;
@end

@implementation LiveView
- (instancetype)initWithCameraName:(NSString *)cameraName
                  resolutionPreset:(NSString *)resolutionPreset
                             error:(NSError **)error {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");

  // Configure Captgure Session

  _isUsingFrontCamera = NO;
  _captureSession = [[AVCaptureSession alloc] init];
  _sessionQueue = dispatch_queue_create(sessionQueueLabel.UTF8String, nil);

  // base example uses AVCaptureVideoPreviewLayer here and the layer is added to a view, Flutter
  // Texture works differently here
  [self setUpCaptureSessionOutputWithResolutionPreset:resolutionPreset];
  [self setUpCaptureSessionInputWithCameraName:cameraName];

  return self;
}

- (void)setDetector:(NSObject<Detector> *)detector withOptions:(NSDictionary *)detectorOptions {
  _currentDetector = detector;
  _currentDetectorOptions = detectorOptions;
}

- (AVCaptureSessionPreset)resolutionPresetForPreference:(NSString *)preference {
  AVCaptureSessionPreset preset;
  if ([preference isEqualToString:@"high"]) {
    preset = AVCaptureSessionPresetHigh;
  } else if ([preference isEqualToString:@"medium"]) {
    preset = AVCaptureSessionPresetMedium;
  } else {
    NSAssert([preference isEqualToString:@"low"], @"Unknown resolution preset %@", preference);
    preset = AVCaptureSessionPresetLow;
  }
  return preset;
}

- (void)setUpCaptureSessionOutputWithResolutionPreset:(NSString *)resolutionPreset {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession beginConfiguration];
    self->_captureSession.sessionPreset = [self resolutionPresetForPreference:resolutionPreset];

    self->_captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
    self->_captureVideoOutput.videoSettings = @{
      (id)
      kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
    };
    dispatch_queue_t outputQueue = dispatch_queue_create(videoDataOutputQueueLabel.UTF8String, nil);
    [self->_captureVideoOutput setSampleBufferDelegate:self queue:outputQueue];
    if ([self.captureSession canAddOutput:self->_captureVideoOutput]) {
      [self.captureSession addOutputWithNoConnections:self->_captureVideoOutput];
      [self.captureSession commitConfiguration];
    } else {
      NSLog(@"%@", @"Failed to add capture session output.");
    }
  });
}

- (void)setUpCaptureSessionInputWithCameraName:(NSString *)cameraName {
  dispatch_async(_sessionQueue, ^{
    AVCaptureDevice *device = [AVCaptureDevice deviceWithUniqueID:cameraName];
    CMVideoDimensions dimensions =
        CMVideoFormatDescriptionGetDimensions([[device activeFormat] formatDescription]);
    self->_previewSize = CGSizeMake(dimensions.width, dimensions.height);
    if (self->_onSizeAvailable) {
      self->_onSizeAvailable(self->_previewSize, self->_captureSize);
    }
    if (device) {
      NSArray<AVCaptureInput *> *currentInputs = self.captureSession.inputs;
      for (AVCaptureInput *input in currentInputs) {
        [self.captureSession removeInput:input];
      }
      NSError *error;
      self->_captureVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];

      if (error) {
        NSLog(@"Failed to create capture device input: %@", error.localizedDescription);
        return;
      } else {
        AVCaptureConnection *connection =
            [AVCaptureConnection connectionWithInputPorts:self->_captureVideoInput.ports
                                                   output:self->_captureVideoOutput];
        connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
        if ([self->_captureDevice position] == AVCaptureDevicePositionFront) {
          connection.videoMirrored = YES;
        }
        [self->_captureSession addInputWithNoConnections:self->_captureVideoInput];
        [self->_captureSession addConnection:connection];
      }
    }
  });
}

- (void)start {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession startRunning];
  });
}

- (void)stop {
  dispatch_async(_sessionQueue, ^{
    [self->_captureSession stopRunning];
  });
}

- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection {
  CVImageBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  if (newBuffer) {
    if (!_isRecognizing) {
      _isRecognizing = YES;
      FIRVisionImage *visionImage = [[FIRVisionImage alloc] initWithBuffer:sampleBuffer];
      FIRVisionImageMetadata *metadata = [[FIRVisionImageMetadata alloc] init];
      UIImageOrientation orientation = [UIUtilities
          imageOrientationFromDevicePosition:_isUsingFrontCamera ? AVCaptureDevicePositionFront
                                                                 : AVCaptureDevicePositionBack];
      FIRVisionDetectorImageOrientation visionOrientation =
          [UIUtilities visionImageOrientationFromImageOrientation:orientation];

      metadata.orientation = visionOrientation;
      visionImage.metadata = metadata;
      [_currentDetector handleDetection:visionImage
          options:_currentDetectorOptions
          finishedCallback:^(id _Nullable result, NSString *detectorType) {
            self->_isRecognizing = NO;
            if (self->_eventSink != nil) {
              self->_eventSink(@{
                @"eventType" : @"detection",
                @"detectionType" : detectorType,
                @"data" : result
              });
            }
          }
          errorCallback:^(FlutterError *error) {
            self->_isRecognizing = NO;
            if (self->_eventSink != nil) {
              self->_eventSink(error);
            }
          }];
    }
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
