// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "FLTImagePickerMetaDataUtil.h"

@interface MetaDataUtilTests : XCTestCase

@property(strong, nonatomic) NSBundle *testBundle;

@end

@implementation MetaDataUtilTests

- (void)setUp {
  self.testBundle = [NSBundle bundleForClass:self.class];
}

- (void)testGetImageMIMETypeFromImageData {
  // test jpeg
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:dataJPG],
                 FLTImagePickerMIMETypeJPEG);

  // test png
  NSData *dataPNG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"pngImage"
                                                                             ofType:@"png"]];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:dataPNG],
                 FLTImagePickerMIMETypePNG);
}

- (void)testSuffixFromType {
  // test jpeg
  XCTAssertEqualObjects(
      [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypeJPEG], @".jpg");

  // test png
  XCTAssertEqualObjects(
      [FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypePNG], @".png");

  // test other
  XCTAssertNil([FLTImagePickerMetaDataUtil imageTypeSuffixFromType:FLTImagePickerMIMETypeOther]);
}

- (void)testGetMetaData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  NSDictionary *metaData = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSDictionary *exif = [metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
  XCTAssertEqual([exif[(NSString *)kCGImagePropertyExifPixelXDimension] integerValue], 12);
}

- (void)testWriteMetaData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  NSDictionary *metaData = [FLTImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSString *tmpFile = [NSString stringWithFormat:@"image_picker_test.jpg"];
  NSString *tmpDirectory = NSTemporaryDirectory();
  NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
  NSData *newData = [FLTImagePickerMetaDataUtil updateMetaData:metaData toImage:dataJPG];
  if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:newData attributes:nil]) {
    NSData *savedTmpImageData = [NSData dataWithContentsOfFile:tmpPath];
    NSDictionary *tmpMetaData =
        [FLTImagePickerMetaDataUtil getMetaDataFromImageData:savedTmpImageData];
    XCTAssert([tmpMetaData isEqualToDictionary:metaData]);
  } else {
    XCTAssert(NO);
  }
}

- (void)testConvertImageToData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSData *convertedDataJPG = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                            usingType:FLTImagePickerMIMETypeJPEG
                                                              quality:@(0.5)];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataJPG],
                 FLTImagePickerMIMETypeJPEG);

  NSData *convertedDataPNG = [FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                            usingType:FLTImagePickerMIMETypePNG
                                                              quality:nil];
  XCTAssertEqual([FLTImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataPNG],
                 FLTImagePickerMIMETypePNG);

  // test throws exceptions
  XCTAssertThrows([FLTImagePickerMetaDataUtil convertImage:imageJPG
                                                 usingType:FLTImagePickerMIMETypePNG
                                                   quality:@(0.5)],
                  @"setting quality when converting to PNG throws exception");
}

- (void)testGetNormalizedUIImageOrientationFromCGImagePropertyOrientation {
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationUp],
      UIImageOrientationUp);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationDown],
      UIImageOrientationDown);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationLeft],
      UIImageOrientationRight);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationRight],
      UIImageOrientationLeft);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationUpMirrored],
      UIImageOrientationUpMirrored);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationDownMirrored],
      UIImageOrientationDownMirrored);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationLeftMirrored],
      UIImageOrientationRightMirrored);
  XCTAssertEqual(
      [FLTImagePickerMetaDataUtil getNormalizedUIImageOrientationFromCGImagePropertyOrientation:
                                      kCGImagePropertyOrientationRightMirrored],
      UIImageOrientationLeftMirrored);
}

@end
