#import "FirebaseMlVisionPlugin.h"
#import "LiveView.h"
#import "NSError+FlutterError.h"

@interface FLTFirebaseMlVisionPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry> *registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger> *messenger;
@property(readonly, nonatomic) LiveView *camera;
@end

@implementation FLTFirebaseMlVisionPlugin
+ (void)handleError:(NSError *)error finishedCallback:(OperationErrorCallback)callback {
  callback([error flutterError]);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_ml_vision"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMlVisionPlugin *instance =
      [[FLTFirebaseMlVisionPlugin alloc] initWithRegistry:[registrar textures]
                                                messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry> *)registry
                       messenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
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
    NSArray<AVCaptureDevice *> *devices;
    if (@available(iOS 10.0, *)) {
      AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession
          discoverySessionWithDeviceTypes:@[ AVCaptureDeviceTypeBuiltInWideAngleCamera ]
                                mediaType:AVMediaTypeVideo
                                 position:AVCaptureDevicePositionUnspecified];
      devices = discoverySession.devices;
    } else {
      // Fallback on earlier versions
      devices = AVCaptureDevice.devices;
    }
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
    LiveView *cam = [[LiveView alloc] initWithCameraName:cameraName
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
        [self->_registry textureFrameAvailable:textureId];
      };
      FlutterEventChannel *eventChannel = [FlutterEventChannel
          eventChannelWithName:
              [NSString
                  stringWithFormat:@"plugins.flutter.io/firebase_ml_vision/liveViewEvents%lld",
                                   textureId]
               binaryMessenger:_messenger];
      [eventChannel setStreamHandler:cam];
      cam.eventChannel = eventChannel;
      cam.onSizeAvailable = ^(CGSize previewSize, CGSize captureSize) {
        result(@{
          @"textureId" : @(textureId),
          @"previewWidth" : @(previewSize.width),
          @"previewHeight" : @(previewSize.height),
          @"captureWidth" : @(captureSize.width),
          @"captureHeight" : @(captureSize.height),
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
  } else if ([@"LiveView#setDetector" isEqualToString:call.method]) {
    NSDictionary *argsMap = call.arguments;
    NSString *detectorType = ((NSString *)argsMap[@"detectorType"]);
    NSDictionary *options = call.arguments[@"options"];
    id detector = [FLTFirebaseMlVisionPlugin detectorForDetectorTypeString:detectorType];
    if (_camera) {
      [_camera setDetector:detector withOptions:options];
    }
    result(nil);
  } else {
    // image file detection
    FIRVisionImage *image = [self filePathToVisionImage:call.arguments[@"path"]];
    NSDictionary *options = call.arguments[@"options"];
    if ([@"BarcodeDetector#detectInImage" isEqualToString:call.method]) {
      [[BarcodeDetector sharedInstance] handleDetection:image
                                                options:options
                                       finishedCallback:[self handleSuccess:result]
                                          errorCallback:[self handleError:result]];
    } else if ([@"FaceDetector#detectInImage" isEqualToString:call.method]) {
      [[FaceDetector sharedInstance] handleDetection:image
                                             options:options
                                    finishedCallback:[self handleSuccess:result]
                                       errorCallback:[self handleError:result]];
    } else if ([@"LabelDetector#detectInImage" isEqualToString:call.method]) {
    } else if ([@"TextDetector#detectInImage" isEqualToString:call.method]) {
      [[TextDetector sharedInstance] handleDetection:image
                                             options:options
                                    finishedCallback:[self handleSuccess:result]
                                       errorCallback:[self handleError:result]];
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

- (OperationFinishedCallback)handleSuccess:(FlutterResult)result {
  return ^(id _Nullable r, NSString *detectorType) {
    result(r);
  };
}

- (OperationErrorCallback)handleError:(FlutterResult)result {
  return ^(FlutterError *error) {
    result(error);
  };
}

+ (NSObject<Detector> *)detectorForDetectorTypeString:(NSString *)detectorType {
  if ([detectorType isEqualToString:@"text"]) {
    return [TextDetector sharedInstance];
  } else if ([detectorType isEqualToString:@"barcode"]) {
    return [BarcodeDetector sharedInstance];
  } else if ([detectorType isEqualToString:@"label"]) {
    return [LabelDetector sharedInstance];
  } else if ([detectorType isEqualToString:@"face"]) {
    return [FaceDetector sharedInstance];
  } else {
    return [TextDetector sharedInstance];
  }
}

- (FIRVisionImage *)filePathToVisionImage:(NSString *)path {
  UIImage *image = [UIImage imageWithContentsOfFile:path];
  return [[FIRVisionImage alloc] initWithImage:image];
}
@end
