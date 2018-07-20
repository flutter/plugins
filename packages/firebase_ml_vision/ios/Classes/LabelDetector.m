#import "FirebaseMlVisionPlugin.h"

@implementation LabelDetector
static FIRVisionLabelDetector *labelDetector;

- (void)close {
  labelDetector = nil;
}

- (void)handleDetection:(FIRVisionImage *)image finishedCallback:(OperationFinishedCallback)callback errorCallback:(OperationErrorCallback)error {
  
}


+ (id)sharedInstance {
  static LabelDetector *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

@end
