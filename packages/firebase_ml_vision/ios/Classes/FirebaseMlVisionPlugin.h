#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

/*
 A callback type to allow the caller to format the detected response
 before it is sent back to Flutter
 */
typedef id (^FlutterResultWrapper)(id _Nullable result);

@interface FLTFirebaseMlVisionPlugin : NSObject<FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

@protocol Detector
@required
+ (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result resultWrapper:(FlutterResultWrapper)wrapper;
+ (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result;
+ (void)close;
@optional
@end

@interface BarcodeDetector : NSObject<Detector>
@end

@interface FaceDetector : NSObject<Detector>
@end

@interface LabelDetector : NSObject<Detector>
@end

@interface TextDetector : NSObject<Detector>
@end
