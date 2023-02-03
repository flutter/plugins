// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>

@import image_picker_ios;
@import image_picker_ios.Test;
@import UniformTypeIdentifiers;
@import XCTest;

@interface PickerSaveImageToPathOperationTests : XCTestCase

@end

@implementation PickerSaveImageToPathOperationTests

- (void)testSaveWebPImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"webpImage"
                                                             withExtension:@"webp"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSavePNGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveJPGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImage"
                                                             withExtension:@"jpg"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveGIFImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"gifImage"
                                                             withExtension:@"gif"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveBMPImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"bmpImage"
                                                             withExtension:@"bmp"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveHEICImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"heicImage"
                                                             withExtension:@"heic"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveICNSImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"icnsImage"
                                                             withExtension:@"icns"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveICOImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"icoImage"
                                                             withExtension:@"ico"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveProRAWImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"proRawImage"
                                                             withExtension:@"dng"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveSVGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"svgImage"
                                                             withExtension:@"svg"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveTIFFImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"tiffImage"
                                                             withExtension:@"tiff"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];
  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testNonexistentImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"bogus"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];

  XCTestExpectation *errorExpectation = [self expectationWithDescription:@"invalid source error"];
  FLTPHPickerSaveImageToPathOperation *operation = [[FLTPHPickerSaveImageToPathOperation alloc]
           initWithResult:result
                maxHeight:@100
                 maxWidth:@100
      desiredImageQuality:@100
             fullMetadata:YES
           savedPathBlock:^(NSString *savedPath, FlutterError *error) {
             XCTAssertEqualObjects(error.code, @"invalid_source");
             [errorExpectation fulfill];
           }];

  [operation start];
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testFailingImageLoad API_AVAILABLE(ios(14)) {
  NSError *loadDataError = [NSError errorWithDomain:@"PHPickerDomain" code:1234 userInfo:nil];

  id mockItemProvider = OCMClassMock([NSItemProvider class]);
  OCMStub([mockItemProvider hasItemConformingToTypeIdentifier:OCMOCK_ANY]).andReturn(YES);
  [[mockItemProvider stub]
      loadDataRepresentationForTypeIdentifier:OCMOCK_ANY
                            completionHandler:[OCMArg invokeBlockWithArgs:[NSNull null],
                                                                          loadDataError, nil]];

  id pickerResult = OCMClassMock([PHPickerResult class]);
  OCMStub([pickerResult itemProvider]).andReturn(mockItemProvider);

  XCTestExpectation *errorExpectation = [self expectationWithDescription:@"invalid image error"];

  FLTPHPickerSaveImageToPathOperation *operation = [[FLTPHPickerSaveImageToPathOperation alloc]
           initWithResult:pickerResult
                maxHeight:@100
                 maxWidth:@100
      desiredImageQuality:@100
             fullMetadata:YES
           savedPathBlock:^(NSString *savedPath, FlutterError *error) {
             XCTAssertEqualObjects(error.code, @"invalid_image");
             XCTAssertEqualObjects(error.message, loadDataError.localizedDescription);
             XCTAssertEqualObjects(error.details, @"PHPickerDomain");
             [errorExpectation fulfill];
           }];

  [operation start];
  [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testSavePNGImageWithoutFullMetadata API_AVAILABLE(ios(14)) {
  id photoAssetUtil = OCMClassMock([PHAsset class]);

  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider];
  OCMReject([photoAssetUtil fetchAssetsWithLocalIdentifiers:OCMOCK_ANY options:OCMOCK_ANY]);

  [self verifySavingImageWithPickerResult:result fullMetadata:NO];
  OCMVerifyAll(photoAssetUtil);
}

/**
 * Creates a mock picker result using NSItemProvider.
 *
 * @param itemProvider an item provider that will be used as picker result
 */
- (PHPickerResult *)createPickerResultWithProvider:(NSItemProvider *)itemProvider
    API_AVAILABLE(ios(14)) {
  PHPickerResult *result = OCMClassMock([PHPickerResult class]);

  OCMStub([result itemProvider]).andReturn(itemProvider);
  OCMStub([result assetIdentifier]).andReturn(itemProvider.registeredTypeIdentifiers.firstObject);

  return result;
}

/**
 * Validates a saving process of FLTPHPickerSaveImageToPathOperation.
 *
 * FLTPHPickerSaveImageToPathOperation is responsible for saving a picked image to the disk for
 * later use. It is expected that the saving is always successful.
 *
 * @param result the picker result
 */
- (void)verifySavingImageWithPickerResult:(PHPickerResult *)result
                             fullMetadata:(BOOL)fullMetadata API_AVAILABLE(ios(14)) {
  XCTestExpectation *pathExpectation = [self expectationWithDescription:@"Path was created"];
  XCTestExpectation *operationExpectation =
      [self expectationWithDescription:@"Operation completed"];

  FLTPHPickerSaveImageToPathOperation *operation = [[FLTPHPickerSaveImageToPathOperation alloc]
           initWithResult:result
                maxHeight:@100
                 maxWidth:@100
      desiredImageQuality:@100
             fullMetadata:fullMetadata
           savedPathBlock:^(NSString *savedPath, FlutterError *error) {
             XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:savedPath]);
             [pathExpectation fulfill];
           }];
  operation.completionBlock = ^{
    [operationExpectation fulfill];
  };

  [operation start];
  [self waitForExpectationsWithTimeout:30 handler:nil];
  XCTAssertTrue(operation.isFinished);
}

@end
