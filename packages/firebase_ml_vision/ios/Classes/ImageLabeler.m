// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseMlVisionPlugin.h"

@interface ImageLabeler ()
@property FIRVisionImageLabeler *labeler;
@end

@implementation ImageLabeler
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    if ([@"onDevice" isEqualToString:options[@"modelType"]]) {
      _labeler = [vision onDeviceImageLabelerWithOptions:[ImageLabeler parseOptions:options]];
    } else if ([@"cloud" isEqualToString:options[@"modelType"]]) {
      _labeler = [vision cloudImageLabelerWithOptions:[ImageLabeler parseCloudOptions:options]];
    } else {
      NSString *reason =
          [NSString stringWithFormat:@"Invalid model type: %@", options[@"modelType"]];
      @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                        reason:reason
                                      userInfo:nil];
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
