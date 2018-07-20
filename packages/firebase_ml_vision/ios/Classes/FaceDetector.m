#import "FirebaseMlVisionPlugin.h"

@implementation FaceDetector
static FIRVisionFaceDetector *faceDetector;

- (void)close {
  faceDetector = nil;
}

- (void)handleDetection:(FIRVisionImage *)image finishedCallback:(OperationFinishedCallback)callback errorCallback:(OperationErrorCallback)error {
  
}

+ (id)sharedInstance {
  static FaceDetector *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

@end
