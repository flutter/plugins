#import "FirebaseMlVisionPlugin.h"

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

@implementation FLTFirebaseMlVisionPlugin
+ (void)handleError:(NSError *)error result:(FlutterResult)result {
  result([error flutterError]);
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_ml_vision"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMlVisionPlugin *instance = [[FLTFirebaseMlVisionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  FIRVisionImage *image = [self dataToVisionImage:call.arguments];
  NSDictionary *options = call.arguments[@"options"];
  if ([@"BarcodeDetector#detectInImage" isEqualToString:call.method]) {
    [BarcodeDetector handleDetection:image options:options result:result];
  } else if ([@"FaceDetector#detectInImage" isEqualToString:call.method]) {
    [FaceDetector handleDetection:image options:options result:result];
  } else if ([@"LabelDetector#detectInImage" isEqualToString:call.method]) {
    [LabelDetector handleDetection:image options:options result:result];
  } else if ([@"CloudLabelDetector#detectInImage" isEqualToString:call.method]) {
    [CloudLabelDetector handleDetection:image options:options result:result];
  } else if ([@"TextRecognizer#processImage" isEqualToString:call.method]) {
    [TextRecognizer handleDetection:image options:options result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FIRVisionImage *)dataToVisionImage:(NSDictionary *)imageData {
  NSString *imageType = imageData[@"type"];

  if ([@"file" isEqualToString:imageType]) {
    UIImage *image = [UIImage imageWithContentsOfFile:imageData[@"path"]];
    return [[FIRVisionImage alloc] initWithImage:image];
  } else if ([@"bytes" isEqualToString:imageType]) {
    FlutterStandardTypedData *byteData = imageData[@"bytes"];
    NSData *imageData = byteData.data;

    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferCreateWithBytes(NULL, 1080, 1920, kCVPixelFormatType_32BGRA, (void *) imageData.bytes, 4352, NULL, NULL, NULL, &pixelBuffer);

    CMVideoFormatDescriptionRef description = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &description);

    CMSampleTimingInfo timingInfo;
    timingInfo.decodeTimeStamp = kCMTimeZero;
    timingInfo.duration = kCMTimeInvalid;
    timingInfo.presentationTimeStamp = kCMTimeInvalid;

    CMSampleBufferRef samplebuffer = NULL;
    CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, description, &timingInfo, &samplebuffer);

    FIRVisionImage *image = [[FIRVisionImage alloc] initWithBuffer:samplebuffer];
    return image;
  } else {
    // TODO(bmparr): Throw illegal argument exception
  }

  return nil;
}
@end
