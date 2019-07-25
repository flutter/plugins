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

- (void)getAssetFromImagePickerInfoShouldReturnNilIfNotAvailable {
  NSDictionary *mockData = @{};
  XCTAssertNil([FLTImagePickerPhotoAssetUtil getAssetFromImagePickerInfo:mockData]);
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveWithTheCorrectExtentionAndMetaData {
  // test jpg
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSString *savedPathJPG = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataJPG
                                                                                  image:imageJPG
                                                                               maxWidth:nil
                                                                              maxHeight:nil];
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
                                                                                  image:imagePNG
                                                                               maxWidth:nil
                                                                              maxHeight:nil];
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

- (void)testSaveImageWithOriginalImageData_ShouldSaveAsGifAnimation {
  // test gif
  NSData *dataGIF = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"gifImage"
                                                                             ofType:@"gif"]];
  UIImage *imageGIF = [UIImage imageWithData:dataGIF];
  CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)dataGIF, nil);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);

  NSNumber *nilSize = (NSNumber *)[NSNull null];
  NSString *savedPathGIF = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataGIF
                                                                                  image:imageGIF
                                                                               maxWidth:nilSize
                                                                              maxHeight:nilSize];
  XCTAssertNotNil(savedPathGIF);
  XCTAssertEqualObjects([savedPathGIF substringFromIndex:savedPathGIF.length - 4], @".gif");

  NSData *newDataGIF = [NSData dataWithContentsOfFile:savedPathGIF];

  CGImageSourceRef newImageSource = CGImageSourceCreateWithData((CFDataRef)newDataGIF, nil);

  size_t newNumberOfFrames = CGImageSourceGetCount(newImageSource);

  XCTAssertEqual(numberOfFrames, newNumberOfFrames);
}

- (void)testSaveImageWithOriginalImageData_ShouldSaveAsScalledGifAnimation {
  // test gif
  NSData *dataGIF = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"gifImage"
                                                                             ofType:@"gif"]];
  UIImage *imageGIF = [UIImage imageWithData:dataGIF];

  CGImageSourceRef imageSource = CGImageSourceCreateWithData((CFDataRef)dataGIF, nil);

  size_t numberOfFrames = CGImageSourceGetCount(imageSource);

  NSString *savedPathGIF = [FLTImagePickerPhotoAssetUtil saveImageWithOriginalImageData:dataGIF
                                                                                  image:imageGIF
                                                                               maxWidth:@3
                                                                              maxHeight:@2];
  NSData *newDataGIF = [NSData dataWithContentsOfFile:savedPathGIF];
  UIImage *newImage = [[UIImage alloc] initWithData:newDataGIF];

  XCTAssertEqual(newImage.size.width, 3);
  XCTAssertEqual(newImage.size.height, 2);

  CGImageSourceRef newImageSource = CGImageSourceCreateWithData((CFDataRef)newDataGIF, nil);

  size_t newNumberOfFrames = CGImageSourceGetCount(newImageSource);

  XCTAssertEqual(numberOfFrames, newNumberOfFrames);
}

@end
