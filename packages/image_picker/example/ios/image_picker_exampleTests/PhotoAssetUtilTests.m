// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FLTImagePickerMetaDataUtil.h"
#import "FLTImagePickerPhotoAssetUtil.h"

@interface PhotoAssetUtilTests : XCTestCase

@property(strong, nonatomic) NSBundle *testBundle;

@end

@implementation PhotoAssetUtilTests

- (void)setUp {
  self.testBundle = [NSBundle bundleForClass:self.class];
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveWithTheCorrectExtentionAndMetaData {
  // test jpg
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataJPG
                                                                                  image:imageJPG];
  XCTAssertNotNil(savedPathJPG);
  XCTAssertEqualObjects([savedPathJPG substringFromIndex:savedPathJPG.length - 4], @".jpg");

  NSDictionary *originalMetaDataJPG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSData *newDataJPG = [NSData dataWithContentsOfFile:savedPathJPG];
  NSDictionary *newMetaDataJPG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:newDataJPG];
  XCTAssertEqualObjects(originalMetaDataJPG[@"ProfileName"], newMetaDataJPG[@"ProfileName"]);

  // test png
  NSData *dataPNG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"pngImage"
                                                                             ofType:@"png"]];
  UIImage *imagePNG = [UIImage imageWithData:dataPNG];
  NSString *savedPathPNG = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataPNG
                                                                                  image:imagePNG];
  XCTAssertNotNil(savedPathPNG);
  XCTAssertEqualObjects([savedPathPNG substringFromIndex:savedPathPNG.length - 4], @".png");

  NSDictionary *originalMetaDataPNG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataPNG];
  NSData *newDataPNG = [NSData dataWithContentsOfFile:savedPathPNG];
  NSDictionary *newMetaDataPNG = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:newDataPNG];
  XCTAssertEqualObjects(originalMetaDataPNG[@"ProfileName"], newMetaDataPNG[@"ProfileName"]);
}

- (void)testSaveImageWithPickerInfo_ShouldSaveWithDefaultExtention {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil
                                                                           image:imageJPG];

  XCTAssertNotNil(savedPathJPG);
  // should be saved as
  XCTAssertEqualObjects([savedPathJPG substringFromIndex:savedPathJPG.length - 4],
                        kFLTImagePickerDefaultSuffix);
}

- (void)testSaveImageWithPickerInfo_ShouldSaveWithTheCorrectExtentionAndMetaData {
  NSDictionary *dummyInfo = @{
    UIImagePickerControllerMediaMetadata : @{
      (__bridge NSString *)kCGImagePropertyExifDictionary :
          @{(__bridge NSString *)kCGImagePropertyExifMakerNote : @"aNote"}
    }
  };
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithPickerInfo:dummyInfo
                                                                           image:imageJPG];
  NSData *data = [NSData dataWithContentsOfFile:savedPathJPG];
  NSDictionary *meta = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:data];
  XCTAssertEqualObjects(meta[(__bridge NSString *)kCGImagePropertyExifDictionary]
                            [(__bridge NSString *)kCGImagePropertyExifMakerNote],
                        @"aNote");
}

@end
