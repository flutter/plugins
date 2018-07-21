#import "FirebaseMlVisionPlugin.h"

@implementation LabelDetector
static FIRVisionLabelDetector *labelDetector;

+ (id)sharedInstance {
  static LabelDetector *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
       finishedCallback:(OperationFinishedCallback)callback
          errorCallback:(OperationErrorCallback)errorCallback {
}

@end
