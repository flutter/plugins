// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <OCMock/OCMock.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@import image_picker_ios;
@import image_picker_ios.Test;
@import XCTest;

@interface PickerSaveItemToPathOperationTests : XCTestCase

@end

@implementation PickerSaveItemToPathOperationTests

- (void)testSaveWebPImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"webpImage"
                                                             withExtension:@"webp"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSavePNGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypePNG.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveJPGImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImage"
                                                             withExtension:@"jpg"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeJPEG.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveGIFImage API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"gifImage"
                                                             withExtension:@"gif"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeGIF.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveMP4Video API_AVAILABLE(ios(14)) {
  NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"mp4Video"
                                                             withExtension:@"mp4"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:videoURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeMPEG4Movie.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveMOVVideo API_AVAILABLE(ios(14)) {
  NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"movVideo"
                                                             withExtension:@"mov"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:videoURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeQuickTimeMovie.identifier];

  [self verifySavingItemWithPickerResult:result];
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
 * Validates a saving process of FLTPHPickerSaveItemToPathOperation.
 *
 * FLTPHPickerSaveItemToPathOperation is responsible for saving a picked item to the disk for
 * later use. It is expected that the saving is always successful.
 *
 * @param result the picker result
 */
- (void)verifySavingItemWithPickerResult:(PHPickerResult *)result API_AVAILABLE(ios(14)) {
  XCTestExpectation *pathExpectation = [self expectationWithDescription:@"Path was created"];

  FLTPHPickerSaveItemToPathOperation *operation = [[FLTPHPickerSaveItemToPathOperation alloc]
           initWithResult:result
           maxImageHeight:@100
            maxImageWidth:@100
      desiredImageQuality:@100
           savedPathBlock:^(NSString *savedPath) {
             if ([[NSFileManager defaultManager] fileExistsAtPath:savedPath]) {
               [pathExpectation fulfill];
             }
           }];

  [operation start];
  [self waitForExpectations:@[ pathExpectation ] timeout:30];
}

@end
