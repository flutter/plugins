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
    NSData *imageBytes = byteData.data;

    NSDictionary *metadata = imageData[@"metadata"];
    NSArray *planeData = metadata[@"planeData"];
    size_t planeCount = planeData.count;

    size_t widths[planeCount];
    size_t heights[planeCount];
    size_t bytesPerRows[planeCount];

    void *baseAddresses[planeCount];
    baseAddresses[0] = (void *)imageBytes.bytes;

    size_t lastAddressIndex = 0;  // Used to get base address for each plane
    for (int i = 0; i < planeCount; i++) {
      NSDictionary *plane = planeData[i];

      NSNumber *width = plane[@"width"];
      NSNumber *height = plane[@"height"];
      NSNumber *bytesPerRow = plane[@"bytesPerRow"];

      widths[i] = width.unsignedLongValue;
      heights[i] = height.unsignedLongValue;
      bytesPerRows[i] = bytesPerRow.unsignedLongValue;

      if (i > 0) {
        size_t addressIndex = lastAddressIndex + heights[i - 1] * bytesPerRows[i - 1];
        baseAddresses[i] = (void *)imageBytes.bytes + addressIndex;
        lastAddressIndex = addressIndex;
      }
    }

    NSNumber *width = metadata[@"width"];
    NSNumber *height = metadata[@"height"];

    NSNumber *rawFormat = metadata[@"rawFormat"];
    FourCharCode format = FOUR_CHAR_CODE(rawFormat.unsignedIntValue);

    CVPixelBufferRef pxbuffer = NULL;
    CVPixelBufferCreateWithPlanarBytes(kCFAllocatorDefault, width.unsignedLongValue,
                                       height.unsignedLongValue, format, NULL, imageBytes.length, 2,
                                       baseAddresses, widths, heights, bytesPerRows, NULL, NULL,
                                       NULL, &pxbuffer);

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pxbuffer];

    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage =
        [temporaryContext createCGImage:ciImage
                               fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pxbuffer),
                                                   CVPixelBufferGetHeight(pxbuffer))];

    UIImage *uiImage = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    return [[FIRVisionImage alloc] initWithImage:uiImage];
  } else {
    NSString *errorReason = [NSString stringWithFormat:@"No image type for: %@", imageType];
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:errorReason
                                 userInfo:nil];
  }
}
@end
