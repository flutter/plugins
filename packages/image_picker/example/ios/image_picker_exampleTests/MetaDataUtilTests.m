// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <XCTest/XCTest.h>
#import "ImagePickerMetaDataUtil.h"

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
  XCTAssertEqual([ImagePickerMetaDataUtil getImageMIMETypeFromImageData:dataJPG],
                 FlutterImagePickerMIMETypeJPEG);

  // test png
  NSData *dataPNG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"pngImage"
                                                                             ofType:@"png"]];
  XCTAssertEqual([ImagePickerMetaDataUtil getImageMIMETypeFromImageData:dataPNG],
                 FlutterImagePickerMIMETypePNG);
}

- (void)testSuffixFromType {
  // test jpeg
  XCTAssertEqualObjects(
      [ImagePickerMetaDataUtil imageTypeSuffixFromType:FlutterImagePickerMIMETypeJPEG], @".jpg");

  // test png
  XCTAssertEqualObjects(
      [ImagePickerMetaDataUtil imageTypeSuffixFromType:FlutterImagePickerMIMETypePNG], @".png");

  // test other
  XCTAssertNil([ImagePickerMetaDataUtil imageTypeSuffixFromType:FlutterImagePickerMIMETypeOther]);
}

- (void)testGetMetaData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  NSDictionary *metaData = [ImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSDictionary *exif = [metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
  XCTAssertEqual([exif[(NSString *)kCGImagePropertyExifPixelXDimension] integerValue], 12);
}

- (void)testGetEXIFData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  NSDictionary *exif = [ImagePickerMetaDataUtil getEXIFFromImageData:dataJPG];
  XCTAssertNotNil(exif);
  // hard coded test case based on the test image file saved in directory.
  XCTAssertEqualObjects(exif[@"PixelXDimension"], @(12));
  XCTAssertEqualObjects(exif[@"PixelYDimension"], @(7));
}

- (void)testWriteEXIFData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  NSDictionary *metaData = [ImagePickerMetaDataUtil getMetaDataFromImageData:dataJPG];
  NSDictionary *exif = [metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
  NSString *tmpFile = [NSString stringWithFormat:@"image_picker_test.jpg"];
  NSString *tmpDirectory = NSTemporaryDirectory();
  NSString *tmpPath = [tmpDirectory stringByAppendingPathComponent:tmpFile];
  NSData *newData = [ImagePickerMetaDataUtil updateEXIFData:exif toImage:dataJPG];
  if ([[NSFileManager defaultManager] createFileAtPath:tmpPath contents:newData attributes:nil]) {
    NSData *savedTmpImageData = [NSData dataWithContentsOfFile:tmpPath];
    NSDictionary *tmpMetaData =
        [ImagePickerMetaDataUtil getMetaDataFromImageData:savedTmpImageData];
    NSDictionary *tmpExif = [tmpMetaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    XCTAssert([tmpExif isEqualToDictionary:exif]);
  } else {
    XCTAssert(NO);
  }
}

- (void)testConvertImageToData {
  NSData *dataJPG = [NSData dataWithContentsOfFile:[self.testBundle pathForResource:@"jpgImage"
                                                                             ofType:@"jpg"]];
  UIImage *imageJPG = [UIImage imageWithData:dataJPG];
  NSData *convertedDataJPG = [ImagePickerMetaDataUtil convertImage:imageJPG
                                                         usingType:FlutterImagePickerMIMETypeJPEG
                                                           quality:@(0.5)];
  XCTAssertEqual([ImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataJPG],
                 FlutterImagePickerMIMETypeJPEG);

  NSData *convertedDataPNG = [ImagePickerMetaDataUtil convertImage:imageJPG
                                                         usingType:FlutterImagePickerMIMETypePNG
                                                           quality:nil];
  XCTAssertEqual([ImagePickerMetaDataUtil getImageMIMETypeFromImageData:convertedDataPNG],
                 FlutterImagePickerMIMETypePNG);

  // test throws exceptions
  XCTAssertThrows([ImagePickerMetaDataUtil convertImage:imageJPG
                                              usingType:FlutterImagePickerMIMETypePNG
                                                quality:@(0.5)],
                  @"setting quality when converting to PNG throws exception");
}
@end
