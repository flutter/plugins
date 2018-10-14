#import "FirebaseMlVisionPlugin.h"

@implementation FaceDetector
static FIRVisionFaceDetector *faceDetector;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  faceDetector = [vision faceDetectorWithOptions:[FaceDetector parseOptions:options]];

  [faceDetector
      processImage:image
        completion:^(NSArray<FIRVisionFace *> *_Nullable faces, NSError *_Nullable error) {
          if (error) {
            [FLTFirebaseMlVisionPlugin handleError:error result:result];
            return;
          } else if (!faces) {
            result(@[]);
            return;
          }

          NSMutableArray *faceData = [NSMutableArray array];
          for (FIRVisionFace *face in faces) {
            id smileProb = face.hasSmilingProbability ? @(face.smilingProbability) : [NSNull null];
            id leftProb =
                face.hasLeftEyeOpenProbability ? @(face.leftEyeOpenProbability) : [NSNull null];
            id rightProb =
                face.hasRightEyeOpenProbability ? @(face.rightEyeOpenProbability) : [NSNull null];

            NSDictionary *data = @{
              @"left" : @((int)face.frame.origin.x),
              @"top" : @((int)face.frame.origin.y),
              @"width" : @((int)face.frame.size.width),
              @"height" : @((int)face.frame.size.height),
              @"headEulerAngleY" : face.hasHeadEulerAngleY ? @(face.headEulerAngleY)
                                                           : [NSNull null],
              @"headEulerAngleZ" : face.hasHeadEulerAngleZ ? @(face.headEulerAngleZ)
                                                           : [NSNull null],
              @"smilingProbability" : smileProb,
              @"leftEyeOpenProbability" : leftProb,
              @"rightEyeOpenProbability" : rightProb,
              @"trackingId" : face.hasTrackingID ? @(face.trackingID) : [NSNull null],
              @"landmarks" : @{
                @"bottomMouth" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeMouthBottom],
                @"leftCheek" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeLeftCheek],
                @"leftEar" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeLeftEar],
                @"leftEye" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeLeftEye],
                @"leftMouth" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeMouthLeft],
                @"noseBase" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeNoseBase],
                @"rightCheek" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeRightCheek],
                @"rightEar" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeRightEar],
                @"rightEye" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeRightEye],
                @"rightMouth" :
                    [FaceDetector getLandmarkPosition:face landmark:FIRFaceLandmarkTypeMouthRight],
              },
            };

            [faceData addObject:data];
          }

          result(faceData);
        }];
}

+ (id)getLandmarkPosition:(FIRVisionFace *)face landmark:(FIRFaceLandmarkType)landmarkType {
  FIRVisionFaceLandmark *landmark = [face landmarkOfType:landmarkType];
  if (landmark) {
    return @[ landmark.position.x, landmark.position.y ];
  }

  return [NSNull null];
}

+ (FIRVisionFaceDetectorOptions *)parseOptions:(NSDictionary *)optionsData {
  FIRVisionFaceDetectorOptions *options = [[FIRVisionFaceDetectorOptions alloc] init];

  NSNumber *enableClassification = optionsData[@"enableClassification"];
  if (enableClassification.boolValue) {
    options.classificationMode = FIRVisionFaceDetectorClassificationModeAll;
  } else {
    options.classificationMode = FIRVisionFaceDetectorClassificationModeNone;
  }

  NSNumber *enableLandmarks = optionsData[@"enableLandmarks"];
  if (enableLandmarks.boolValue) {
    options.landmarkMode = FIRVisionFaceDetectorLandmarkModeAll;
  } else {
    options.landmarkMode = FIRVisionFaceDetectorLandmarkModeNone;
  }

  NSNumber *enableTracking = optionsData[@"enableTracking"];
  options.trackingEnabled = enableTracking.boolValue;

  NSNumber *minFaceSize = optionsData[@"minFaceSize"];
  options.minFaceSize = [minFaceSize doubleValue];

  NSString *mode = optionsData[@"mode"];
  if ([mode isEqualToString:@"accurate"]) {
    options.performanceMode = FIRVisionFaceDetectorPerformanceModeAccurate;
  } else if ([mode isEqualToString:@"fast"]) {
    options.performanceMode = FIRVisionFaceDetectorPerformanceModeFast;
  }

  return options;
}
@end
