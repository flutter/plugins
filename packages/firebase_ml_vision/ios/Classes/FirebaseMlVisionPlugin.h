#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

/*
 A callback type to allow the caller to format the detected response
 before it is sent back to Flutter
 */
typedef void (^OperationFinishedCallback)(id _Nullable result, NSString *detectorType);
typedef void (^OperationErrorCallback)(FlutterError *error);

@interface FLTFirebaseMlVisionPlugin : NSObject<FlutterPlugin>
+ (void)handleError:(NSError *)error finishedCallback:(OperationErrorCallback)callback;
@end

@protocol Detector
@required
+ (id)sharedInstance;
- (void)handleDetection:(FIRVisionImage *)image finishedCallback:(OperationFinishedCallback)callback errorCallback:(OperationErrorCallback)error;
- (void)close;
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
