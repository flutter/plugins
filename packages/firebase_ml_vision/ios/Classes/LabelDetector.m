#import "FirebaseMlVisionPlugin.h"

@implementation LabelDetector
static FIRVisionLabelDetector *detector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  detector = [vision labelDetectorWithOptions:[LabelDetector parseOptions:options]];

  [detector detectInImage:image
               completion:^(NSArray<FIRVisionLabel *> *_Nullable labels, NSError *_Nullable error) {
                 if (error) {
                   [FLTFirebaseMlVisionPlugin handleError:error result:result];
                   return;
                 } else if (!labels) {
                   result(@[]);
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

                 result(labelData);
               }];
}

+ (FIRVisionLabelDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];
  return [[FIRVisionLabelDetectorOptions alloc] initWithConfidenceThreshold:[conf floatValue]];
}
@end
