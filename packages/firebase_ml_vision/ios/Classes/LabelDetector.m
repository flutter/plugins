#import "FirebaseMlVisionPlugin.h"

@implementation LabelDetector
static FIRVisionLabelDetector *detector;

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
  FIRVision *vision = [FIRVision vision];
  detector = [vision labelDetectorWithOptions:[LabelDetector parseOptions:options]];

  [detector detectInImage:image
               completion:^(NSArray<FIRVisionLabel *> *_Nullable labels, NSError *_Nullable error) {
                 if (error) {
                   [FLTFirebaseMlVisionPlugin handleError:error finishedCallback:errorCallback];
                   return;
                 } else if (!labels) {
                   callback(@[], @"label");
                 }

                 NSMutableArray *labelData = [NSMutableArray array];
                 for (FIRVisionLabel *label in labels) {
                   NSDictionary *data = @{
                     @"confidence" : @(label.confidence),
                     @"entityID" : label.entityID,
                     @"label" : label.label
                   };
                   [labelData addObject:data];
                 }

                 callback(labelData, @"label");
               }];
}

+ (FIRVisionLabelDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];
  return [[FIRVisionLabelDetectorOptions alloc] initWithConfidenceThreshold:[conf floatValue]];
}
@end
