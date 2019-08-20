// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseMlVisionPlugin.h"

@interface FaceDetector ()
@property FIRVisionFaceDetector *detector;
@end

@implementation FaceDetector
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    _detector = [vision faceDetectorWithOptions:[FaceDetector parseOptions:options]];
  }
  return self;
}

- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  [_detector
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
              @"left" : @(face.frame.origin.x),
              @"top" : @(face.frame.origin.y),
              @"width" : @(face.frame.size.width),
              @"height" : @(face.frame.size.height),
              @"headEulerAngleY" : face.hasHeadEulerAngleY ? @(face.headEulerAngleY)
                                                           : [NSNull null],
              @"headEulerAngleZ" : face.hasHeadEulerAngleZ ? @(face.headEulerAngleZ)
                                                           : [NSNull null],
              @"smilingProbability" : smileProb,
              @"leftEyeOpenProbability" : leftProb,
              @"rightEyeOpenProbability" : rightProb,
              @"trackingId" : face.hasTrackingID ? @(face.trackingID) : [NSNull null],
              @"landmarks" : @{
                @"bottomMouth" : [FaceDetector getLandmarkPosition:face
                                                          landmark:FIRFaceLandmarkTypeMouthBottom],
                @"leftCheek" : [FaceDetector getLandmarkPosition:face
                                                        landmark:FIRFaceLandmarkTypeLeftCheek],
                @"leftEar" : [FaceDetector getLandmarkPosition:face
                                                      landmark:FIRFaceLandmarkTypeLeftEar],
                @"leftEye" : [FaceDetector getLandmarkPosition:face
                                                      landmark:FIRFaceLandmarkTypeLeftEye],
                @"leftMouth" : [FaceDetector getLandmarkPosition:face
                                                        landmark:FIRFaceLandmarkTypeMouthLeft],
                @"noseBase" : [FaceDetector getLandmarkPosition:face
                                                       landmark:FIRFaceLandmarkTypeNoseBase],
                @"rightCheek" : [FaceDetector getLandmarkPosition:face
                                                         landmark:FIRFaceLandmarkTypeRightCheek],
                @"rightEar" : [FaceDetector getLandmarkPosition:face
                                                       landmark:FIRFaceLandmarkTypeRightEar],
                @"rightEye" : [FaceDetector getLandmarkPosition:face
                                                       landmark:FIRFaceLandmarkTypeRightEye],
                @"rightMouth" : [FaceDetector getLandmarkPosition:face
                                                         landmark:FIRFaceLandmarkTypeMouthRight],
              },
              @"contours" : @{
                @"allPoints" : [FaceDetector getContourPoints:face contour:FIRFaceContourTypeAll],
                @"face" : [FaceDetector getContourPoints:face contour:FIRFaceContourTypeFace],
                @"leftEye" : [FaceDetector getContourPoints:face contour:FIRFaceContourTypeLeftEye],
                @"leftEyebrowBottom" :
                    [FaceDetector getContourPoints:face
                                           contour:FIRFaceContourTypeLeftEyebrowBottom],
                @"leftEyebrowTop" :
                    [FaceDetector getContourPoints:face contour:FIRFaceContourTypeLeftEyebrowTop],
                @"lowerLipBottom" :
                    [FaceDetector getContourPoints:face contour:FIRFaceContourTypeLowerLipBottom],
                @"lowerLipTop" : [FaceDetector getContourPoints:face
                                                        contour:FIRFaceContourTypeLowerLipTop],
                @"noseBottom" : [FaceDetector getContourPoints:face
                                                       contour:FIRFaceContourTypeNoseBottom],
                @"noseBridge" : [FaceDetector getContourPoints:face
                                                       contour:FIRFaceContourTypeNoseBridge],
                @"rightEye" : [FaceDetector getContourPoints:face
                                                     contour:FIRFaceContourTypeRightEye],
                @"rightEyebrowBottom" :
                    [FaceDetector getContourPoints:face
                                           contour:FIRFaceContourTypeRightEyebrowBottom],
                @"rightEyebrowTop" :
                    [FaceDetector getContourPoints:face contour:FIRFaceContourTypeRightEyebrowTop],
                @"upperLipBottom" :
                    [FaceDetector getContourPoints:face contour:FIRFaceContourTypeUpperLipBottom],
                @"upperLipTop" : [FaceDetector getContourPoints:face
                                                        contour:FIRFaceContourTypeUpperLipTop],
              }
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

+ (id)getContourPoints:(FIRVisionFace *)face contour:(FIRFaceContourType)contourType {
  FIRVisionFaceContour *contour = [face contourOfType:contourType];
  if (contour) {
    NSArray<FIRVisionPoint *> *contourPoints = contour.points;
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[contourPoints count]];
    for (int i = 0; i < [contourPoints count]; i++) {
      FIRVisionPoint *point = [contourPoints objectAtIndex:i];
      [result insertObject:@[ point.x, point.y ] atIndex:i];
    }
    return [result copy];
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

  NSNumber *enableContours = optionsData[@"enableContours"];
  if (enableContours.boolValue) {
    options.contourMode = FIRVisionFaceDetectorContourModeAll;
  } else {
    options.contourMode = FIRVisionFaceDetectorContourModeNone;
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
