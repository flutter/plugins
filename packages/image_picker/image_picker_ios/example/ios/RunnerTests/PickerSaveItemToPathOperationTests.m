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

- (void)testSaveWebPImageFromResult API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"webpImage"
                                                             withExtension:@"webp"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeWebP.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSavePNGImageFromResult API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                             withExtension:@"png"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypePNG.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveJPGImageFromResult API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImage"
                                                             withExtension:@"jpg"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeJPEG.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveGIFImageFromResult API_AVAILABLE(ios(14)) {
  NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"gifImage"
                                                             withExtension:@"gif"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:imageURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeGIF.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveMP4VideoFromResult API_AVAILABLE(ios(14)) {
  NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"mp4Video"
                                                             withExtension:@"mp4"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:videoURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeMPEG4Movie.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveMOVVideoFromResult API_AVAILABLE(ios(14)) {
  NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"movVideo"
                                                             withExtension:@"mov"];
  NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:videoURL];
  PHPickerResult *result = [self createPickerResultWithProvider:itemProvider
                                                 withIdentifier:UTTypeQuickTimeMovie.identifier];

  [self verifySavingItemWithPickerResult:result];
}

- (void)testSaveWebPImageFromAsset {
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"webpImage"
                                                               withExtension:@"webp"];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    OCMStub([imageManagerMock requestImageForAsset:[OCMArg anyPointer]
                                        targetSize:CGSizeMake(0,0)
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:([OCMArg invokeBlockWithArgs:OCMOCK_VALUE(image), OCMOCK_VALUE([NSNull null]), nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeImage);

  [self verifySavingItemWithAsset:asset];
}

- (void)testSavePNGImageFromAsset {
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"pngImage"
                                                               withExtension:@"png"];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    OCMStub([imageManagerMock requestImageForAsset:[OCMArg anyPointer]
                                        targetSize:CGSizeMake(0,0)
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:([OCMArg invokeBlockWithArgs:image, nil, nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeImage);

  [self verifySavingItemWithAsset:asset];
}

- (void)testSaveJPGImageFromAsset {
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"jpgImage"
                                                               withExtension:@"jpg"];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    OCMStub([imageManagerMock requestImageForAsset:[OCMArg anyPointer]
                                        targetSize:CGSizeMake(0,0)
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:([OCMArg invokeBlockWithArgs:image, nil, nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeImage);

  [self verifySavingItemWithAsset:asset];
}

- (void)testSaveGIFImageFromAsset{
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *imageURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"gifImage"
                                                               withExtension:@"gif"];
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    OCMStub([imageManagerMock requestImageForAsset:[OCMArg anyPointer]
                                        targetSize:CGSizeMake(0,0)
                                       contentMode:PHImageContentModeDefault
                                           options:nil
                                     resultHandler:([OCMArg invokeBlockWithArgs:image, nil, nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeImage);

  [self verifySavingItemWithAsset:asset];
}

- (void)testSaveMP4VideoFromAsset {
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"mp4Video"
                                                               withExtension:@"mp4"];
    AVURLAsset* urlAsset = OCMClassMock([AVURLAsset class]);
    OCMStub([urlAsset URL]).andReturn(videoURL);
    OCMStub([imageManagerMock requestAVAssetForVideo:[OCMArg anyPointer]
                                             options:[OCMArg anyPointer]
                                     resultHandler:([OCMArg invokeBlockWithArgs:urlAsset, nil, nil, nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeVideo);

  [self verifySavingItemWithAsset:asset];
}

- (void)testSaveMOVVideoFromAsset {
    id imageManagerMock = OCMClassMock([PHImageManager class]);
    OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
    NSURL *videoURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"movVideo"
                                                               withExtension:@"mov"];
    AVURLAsset* urlAsset = OCMClassMock([AVURLAsset class]);
    OCMStub([urlAsset URL]).andReturn(videoURL);
    OCMStub([imageManagerMock requestAVAssetForVideo:[OCMArg anyPointer]
                                             options:[OCMArg anyPointer]
                                     resultHandler:([OCMArg invokeBlockWithArgs:urlAsset, nil, nil, nil])
            ]);
    PHAsset *asset = OCMClassMock([PHAsset class]);
    OCMStub([asset mediaType]).andReturn(PHAssetMediaTypeVideo);

  [self verifySavingItemWithAsset:asset];
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

/**
 * Validates a saving process of FLTPHPickerSaveItemToPathOperation.
 *
 * FLTPHPickerSaveItemToPathOperation is responsible for saving a picked item to the disk for
 * later use. It is expected that the saving is always successful.
 *
 * @param result the picker result
 */
- (void)verifySavingItemWithAsset:(PHAsset *)asset {
  XCTestExpectation *pathExpectation = [self expectationWithDescription:@"Path was created"];

  FLTPHPickerSaveItemToPathOperation *operation = [[FLTPHPickerSaveItemToPathOperation alloc]
           initWithAsset:asset
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
