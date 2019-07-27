#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@interface RemoteVisionEdgeDetector ()
@property FIRVisionImageLabeler *labeler;
@end

@implementation RemoteVisionEdgeDetector

- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
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
      _labeler = [[FIRVision vision]
          onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
    } else {
      Boolean isModelDownloaded =
          [[FIRModelManager modelManager] isRemoteModelDownloaded:remoteModel];
      if (isModelDownloaded == true) {
        _labeler = [[FIRVision vision]
            onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      } else {
        [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
        _labeler = [[FIRVision vision]
            onDeviceAutoMLImageLabelerWithOptions:[RemoteVisionEdgeDetector parseOptions:options]];
      }
    }
  }
  return self;
}

- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  [_labeler
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
