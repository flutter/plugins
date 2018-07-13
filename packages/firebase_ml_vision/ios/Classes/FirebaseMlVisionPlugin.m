#import "FirebaseMlVisionPlugin.h"
#import "LiveView.h"

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

@interface FLTFirebaseMlVisionPlugin()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) FLTCam *camera;
@end

@implementation FLTFirebaseMlVisionPlugin
+ (void)handleError:(NSError *)error result:(FlutterResult)result {
  result([error flutterError]);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_ml_vision"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMlVisionPlugin *instance = [[FLTFirebaseMlVisionPlugin alloc] initWithRegistry:[registrar textures] messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  if (![FIRApp defaultApp]) {
    [FIRApp configure];
  }
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
      NSLog(@"initialize called");
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
                                                                 stringWithFormat:@"plugins.flutter.io/firebase_ml_vision/liveViewEvents%lld",
                                                                 textureId]
                                           binaryMessenger:_messenger];
      [eventChannel setStreamHandler:cam];
      cam.eventChannel = eventChannel;
      cam.onSizeAvailable = ^{
        result(@{
                 @"textureId" : @(textureId),
                 @"previewWidth" : @(cam.previewSize.width),
                 @"previewHeight" : @(cam.previewSize.height),
                 @"captureWidth" : @(cam.captureSize.width),
                 @"captureHeight" : @(cam.captureSize.height),
                 });
      };
      [cam start];
    }
  } else if ([@"dispose" isEqualToString:call.method]) {
    NSDictionary *argsMap = call.arguments;
    NSUInteger textureId = ((NSNumber *)argsMap[@"textureId"]).unsignedIntegerValue;
    [_registry unregisterTexture:textureId];
    [_camera close];
    result(nil);
  } else if ([@"LiveView#setRecognizer" isEqualToString:call.method]) {
    NSLog(@"setRecognizer called");
    NSDictionary *argsMap = call.arguments;
    NSString *recognizerType = ((NSString *)argsMap[@"recognizerType"]);
    NSLog(recognizerType);
    if (_camera) {
      NSLog(@"got a camera, setting the recognizer");
//      [_camera setRecognizerType:recognizerType];
    }
    result(nil);
  } else if ([@"BarcodeDetector#detectInImage" isEqualToString:call.method]) {
    FIRVisionImage *image = [self filePathToVisionImage:call.arguments];
    [BarcodeDetector handleDetection:image result:result];
  } else if ([@"BarcodeDetector#close" isEqualToString:call.method]) {
    [BarcodeDetector close];
  } else if ([@"FaceDetector#detectInImage" isEqualToString:call.method]) {
  } else if ([@"FaceDetector#close" isEqualToString:call.method]) {
  } else if ([@"LabelDetector#detectInImage" isEqualToString:call.method]) {
  } else if ([@"LabelDetector#close" isEqualToString:call.method]) {
  } else if ([@"TextDetector#detectInImage" isEqualToString:call.method]) {
    FIRVisionImage *image = [self filePathToVisionImage:call.arguments];
    [TextDetector handleDetection:image result:result];
  } else if ([@"TextDetector#close" isEqualToString:call.method]) {
    [TextDetector close];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FIRVisionImage *)filePathToVisionImage:(NSString *)path {
  UIImage *image = [UIImage imageWithContentsOfFile:path];
  return [[FIRVisionImage alloc] initWithImage:image];
}
@end
