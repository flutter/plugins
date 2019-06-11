#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

@interface FLTFirebaseMlVisionPlugin : NSObject <FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

@protocol Detector
@required
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options;
- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result;
@optional
@end

@interface BarcodeDetector : NSObject <Detector>
@end

@interface FaceDetector : NSObject <Detector>
@end

@interface ImageLabeler : NSObject <Detector>
@end

@interface TextRecognizer : NSObject <Detector>
@end
