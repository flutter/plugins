#import "FirebaseMlVisionPlugin.h"

@implementation LabelDetector
static FIRVisionCloudLandmarkDetector *detector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  FIRVisionCloudDetectorOptions *detectorOptions =
      [FLTFirebaseMlVisionPlugin parseCloudDetectorOptions:options];

  detector = [vision cloudLandmarkDetectorWithOptions:detectorOptions];

  [detector detectInImage:image
               completion:^(NSArray<FIRVisionCloudLandmark *> *_Nullable landmarks,
                            NSError *_Nullable error) {
                 if (error) {
                   [FLTFirebaseMlVisionPlugin handleError:error result:result];
                   return;
                 } else if (!landmarks) {
                   result(@[]);
                 }

                 NSMutableArray *landmarkData = [NSMutableArray array];
                 for (FIRVisionCloudLandmark *landmark in landmarks) {
                   __block NSMutableArray<NSDictionary *> *locations = [NSMutableArray array];
                   for (FIRVisionLatitudeLongitude *latLng in landmark.locations) {
                     [locations addObject:@{
                       @"latitude" : latLng.latitude,
                       @"longitude" : latLng.longitude,
                     }];
                   }

                   NSDictionary *data = @{
                     @"confidence" : landmark.confidence,
                     @"entityId" : landmark.entityId,
                     @"landmark" : landmark.landmark,
                     @"left" : @((int)landmark.frame.origin.x),
                     @"top" : @((int)landmark.frame.origin.y),
                     @"width" : @((int)landmark.frame.size.width),
                     @"height" : @((int)landmark.frame.size.height),
                     @"locations" : locations,
                   };

                   [landmarkData addObject:data];
                 }

                 result(landmarkData);
               }];
}
@end
