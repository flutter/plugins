// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@import image_picker_ios;
@import image_picker_ios.Test;
@import XCTest;

@interface PickerSaveImageToPathOperationTests : XCTestCase

@end

@implementation PickerSaveImageToPathOperationTests

- (void)testSaveWebPImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"webpImage"
                                                             withExtension:@"webp"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSavePNGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveJPGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImage"
                                                             withExtension:@"jpg"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSaveGIFImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"gifImage"
                                                             withExtension:@"gif"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingImageWithPickerResult:result fullMetadata:YES];
}

- (void)testSavePNGImageWithoutFullMetadata API_AVAILABLE(ios(14)) {
  id photoAssetUtil = OCMClassMock([PHAsset class]);

  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingImageWithPickerResult:result fullMetadata:NO];
  OCMVerify(times(0), [photoAssetUtil fetchAssetsWithLocalIdentifiers:[OCMArg any]
                                                              options:[OCMArg any]]);
}

/**
 * Creates a mock picker result using NSItemProvider.
 *
 * @param itemProvider an item provider that will be used as picker result
 * @param identifier local identifier of the asset
 */
- (PHPickerResult *)createPickerResultWithProvider:(NSItemProvider *)itemProvider
                                    withIdentifier:(NSString *)identifier API_AVAILABLE(ios(14)) {
  PHPickerResult *result = OCMClassMock([PHPickerResult class]);

  OCMStub([result itemProvider]).andReturn(itemProvider);
  OCMStub([result assetIdentifier]).andReturn(identifier);

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

  FLTPHPickerSaveImageToPathOperation *operation = [[FLTPHPickerSaveImageToPathOperation alloc]
           initWithResult:result
                maxHeight:@100
                 maxWidth:@100
      desiredImageQuality:@100
             fullMetadata:fullMetadata
           savedPathBlock:^(NSString *savedPath) {
             if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
               [pathExpectation fulfill];
             }
           }];

  [operation start];
  [self waitForExpectations:@[ pathExpectation ] timeout:30];
}

@end
