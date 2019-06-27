#import "FirebaseMlVisionPlugin.h"

@implementation ImageLabeler
static FIRVisionImageLabeler *labeler;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];

  if ([@"onDevice" isEqualToString:options[@"modelType"]]) {
    labeler = [vision onDeviceImageLabelerWithOptions:[ImageLabeler parseOptions:options]];
  } else if ([@"cloud" isEqualToString:options[@"modelType"]]) {
    labeler = [vision cloudImageLabelerWithOptions:[ImageLabeler parseCloudOptions:options]];
  }

  [labeler
      processImage:image
        completion:^(NSArray<FIRVisionImageLabel *> *_Nullable labels, NSError *_Nullable error) {
          if (error) {
            [FLTFirebaseMlVisionPlugin handleError:error result:result];
            return;
          } else if (!labels) {
            result(@[]);
          }

          NSMutableArray *labelData = [NSMutableArray array];
          for (FIRVisionImageLabel *label in labels) {
            NSDictionary *data = @{
              @"confidence" : label.confidence,
              @"entityID" : label.entityID,
              @"text" : label.text,
            };
            [labelData addObject:data];
          }

          result(labelData);
        }];
}

+ (FIRVisionOnDeviceImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];

  FIRVisionOnDeviceImageLabelerOptions *options = [FIRVisionOnDeviceImageLabelerOptions new];
  options.confidenceThreshold = [conf floatValue];

  return options;
}

+ (FIRVisionCloudImageLabelerOptions *)parseCloudOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];

  FIRVisionCloudImageLabelerOptions *options = [FIRVisionCloudImageLabelerOptions new];
  options.confidenceThreshold = [conf floatValue];

  return options;
}
@end
