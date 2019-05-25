#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@implementation RemoteVisionEdgeDetector

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRRemoteModel *remoteModel =
      [[FIRModelManager modelManager] remoteModelWithName:options[@"dataset"]];
  if (remoteModel == nil) {
    FIRModelDownloadConditions *conditions =
        [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                             allowsBackgroundDownloading:YES];
    FIRRemoteModel *remoteModel = [[FIRRemoteModel alloc] initWithName:options[@"dataset"]
                                                    allowsModelUpdates:YES
                                                     initialConditions:conditions
                                                      updateConditions:conditions];
    [[FIRModelManager modelManager] registerRemoteModel:remoteModel];
    [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
    FIRVisionImageLabeler *labeler = [[FIRVision vision]
        onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
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
                @"text" : label.text,
              };
              [labelData addObject:data];
            }

            result(labelData);
          }];
  } else {
    Boolean isModelDownloaded =
        [[FIRModelManager modelManager] isRemoteModelDownloaded:remoteModel];
    if (isModelDownloaded == true) {
      FIRVisionImageLabeler *labeler = [[FIRVision vision]
          onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      [labeler processImage:image
                 completion:^(NSArray<FIRVisionImageLabel *> *_Nullable labels,
                              NSError *_Nullable error) {
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
                       @"text" : label.text,
                     };
                     [labelData addObject:data];
                   }

                   result(labelData);
                 }];
    } else {
      [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
      FIRVisionImageLabeler *labeler = [[FIRVision vision]
          onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      [labeler processImage:image
                 completion:^(NSArray<FIRVisionImageLabel *> *_Nullable labels,
                              NSError *_Nullable error) {
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
                       @"text" : label.text,
                     };
                     [labelData addObject:data];
                   }

                   result(labelData);
                 }];
    }
  }
}

+ (FIRVisionOnDeviceAutoMLImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];
  NSString *dataset = optionsData[@"dataset"];

  FIRVisionOnDeviceAutoMLImageLabelerOptions *options =
      [[FIRVisionOnDeviceAutoMLImageLabelerOptions alloc] initWithRemoteModelName:dataset
                                                                   localModelName:nil];
  options.confidenceThreshold = [conf floatValue];

  return options;
}

@end
