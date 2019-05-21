#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@implementation VisionEdgeDetector

+ (void)handleDetection:(FIRVisionImage *)image options:(NSDictionary *)options result:(FlutterResult)result {
    NSString *pathStart = @"Frameworks/App.framework/flutter_assets/assets/";
    NSString *datasetAppended = [pathStart stringByAppendingString:options[@"dataset"]];
    NSString *finalPath = [datasetAppended stringByAppendingString:@"/manifest.json"];
    NSString *manifestPath = [[NSBundle mainBundle] pathForResource:finalPath ofType:nil];
    FIRLocalModel *localModel = [[FIRLocalModel alloc] initWithName:options[@"dataset"]
        path:manifestPath];
    [[FIRModelManager modelManager] registerLocalModel:localModel];
    FIRVisionImageLabeler *labeler =
    [[FIRVision vision] onDeviceAutoMLImageLabelerWithOptions:[VisionEdgeDetector parseOptions: options]];
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
}

+ (FIRVisionOnDeviceAutoMLImageLabelerOptions *)parseOptions:(NSDictionary *)optionsData {
    NSNumber *conf = optionsData[@"confidenceThreshold"];
    NSString *dataset = optionsData[@"dataset"];
    
    FIRVisionOnDeviceAutoMLImageLabelerOptions *options =
        [[FIRVisionOnDeviceAutoMLImageLabelerOptions alloc]
         initWithRemoteModelName: nil
         localModelName: dataset];
    options.confidenceThreshold = [conf floatValue];
    
    return options;
}

@end
