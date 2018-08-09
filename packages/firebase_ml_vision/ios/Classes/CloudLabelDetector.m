#import "FirebaseMlVisionPlugin.h"

@implementation CloudLabelDetector
static FIRVisionCloudLabelDetector *detector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  detector = [vision cloudLabelDetectorWithOptions:[CloudLabelDetector parseOptions:options]];

  [detector
      detectInImage:image
         completion:^(NSArray<FIRVisionCloudLabel *> *_Nullable labels, NSError *_Nullable error) {
           if (error) {
             [FLTFirebaseMlVisionPlugin handleError:error result:result];
             return;
           } else if (!labels) {
             result(@[]);
           }

           NSMutableArray *labelData = [NSMutableArray array];
           for (FIRVisionCloudLabel *label in labels) {
             NSDictionary *data = @{
               @"confidence" : label.confidence,
               @"entityId" : label.entityId,
               @"label" : label.label
             };
             [labelData addObject:data];
           }

           result(labelData);
         }];
}

+ (FIRVisionCloudDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  FIRVisionCloudDetectorOptions *detector = [[FIRVisionCloudDetectorOptions alloc] init];

  NSNumber *modelType = optionsData[@"modelType"];
  detector.modelType = (FIRVisionCloudModelType)[modelType intValue];

  NSNumber *maxResults = optionsData[@"maxResults"];
  detector.maxResults = [maxResults unsignedIntegerValue];

  return detector;
}
@end
