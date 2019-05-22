// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "ImagePickerMetaDataUtil.h"
#import "ImagePickerPhotoAssetUtil.h"

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
  NSString *savedPathJPG = [ImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataJPG
                                                                               image:imageJPG];
  XCTAssertNotNil(savedPathJPG);
  XCTAssertEqualObjects([savedPathJPG substringFromIndex:savedPathJPG.length - 4], @".jpg");

  // test png
  NSData *dataPNG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"pngImage"
                                                                             ofType:@"png"]];
  UIImage *imagePNG = [UIImage imageWithData:dataPNG];
  NSString *savedPathPNG = [ImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataPNG
                                                                               image:imagePNG];
  XCTAssertNotNil(savedPathPNG);
  XCTAssertEqualObjects([savedPathPNG substringFromIndex:savedPathPNG.length - 4], @".png");
}

- (void)testSaveImageWithPickerInfo_ShouldSaveWithDefaultExtention {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [ImagePickerPhotoAssetUtil saveImageWithPickerInfo:nil image:imageJPG];

  XCTAssertNotNil(savedPathJPG);
  // should be saved as
  XCTAssertEqualObjects([savedPathJPG substringFromIndex:savedPathJPG.length - 4],
                        kFlutterImagePickerDefaultSuffix);
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
  NSString *savedPathJPG = [ImagePickerPhotoAssetUtil saveImageWithPickerInfo:dummyInfo
                                                                        image:imageJPG];
  NSData *data = [NSData dataWithContentsOfFile:savedPathJPG];
  NSDictionary *exif = [ImagePickerMetaDataUtil getEXIFFromImageData:data];
  XCTAssertEqualObjects(exif[(__bridge NSString *)kCGImagePropertyExifMakerNote], @"aNote");
}

@end
