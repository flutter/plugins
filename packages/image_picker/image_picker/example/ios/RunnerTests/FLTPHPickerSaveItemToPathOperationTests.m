// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import image_picker.Test;
@import XCTest;
#import <OCMock/OCMock.h>
#import <PhotosUI/PhotosUI.h>

typedef void (^GetSavedPath)(NSString *);

API_AVAILABLE(ios(14))
@interface FLTPHPickerSaveItemToPathOperation (Test)
@property(strong, nonatomic) PHPickerResult *result;
@property(assign, nonatomic) NSNumber *maxHeight;
@property(assign, nonatomic) NSNumber *maxWidth;
@property(assign, nonatomic) NSNumber *desiredImageQuality;
- (void)setFinished:(BOOL)isFinished;
- (void)setExecuting:(BOOL)isExecuting;
- (void)completeOperationWithPath:(NSString *)savedPath;
- (void)start;
- (PHAsset *)getAssetFromPHPickerResult:(PHPickerResult *)result;
- (NSString *)saveImageWithPickerInfo:(nullable NSDictionary *)info
                                image:(UIImage *)image
                         imageQuality:(NSNumber *)imageQuality;
- (UIImage *)scaledImage:(UIImage *)image
                maxWidth:(NSNumber *)maxWidth
               maxHeight:(NSNumber *)maxHeight
     isMetadataAvailable:(BOOL)isMetadataAvailable;
- (NSString *)saveImageWithOriginalImageData:(NSData *)originalImageData
                                       image:(UIImage *)image
                                    maxWidth:(NSNumber *)maxWidth
                                   maxHeight:(NSNumber *)maxHeight
                                imageQuality:(NSNumber *)imageQuality;
@end

@interface FLTPHPickerSaveItemToPathOperationTests : XCTestCase

@end

API_AVAILABLE(ios(14))
@implementation FLTPHPickerSaveItemToPathOperationTests

FLTPHPickerSaveItemToPathOperation *operation;
PHPickerResult *mockResult API_AVAILABLE(ios(14));

- (void)setUp {
  mockResult = OCMClassMock([PHPickerResult class]);
  operation = [[FLTPHPickerSaveItemToPathOperation alloc] initWithResult:mockResult
                                                          maxImageHeight:(id)[NSNull null]
                                                           maxImageWidth:(id)[NSNull null]
                                                     desiredImageQuality:(id)[NSNull null]
                                                          savedPathBlock:^(NSString *savedPath){
                                                          }];
}

- (void)testInitializesWithParameters {
  operation = [[FLTPHPickerSaveItemToPathOperation alloc] initWithResult:mockResult
                                                          maxImageHeight:@1
                                                           maxImageWidth:@1
                                                     desiredImageQuality:@1
                                                          savedPathBlock:^(NSString *savedPath){
                                                          }];
  XCTAssertEqualObjects(operation.result, mockResult);
  XCTAssertEqual(operation.maxWidth, @1);
  XCTAssertEqual(operation.maxHeight, @1);
  XCTAssertEqual(operation.desiredImageQuality, @1);
  XCTAssertEqual(operation.isExecuting, NO);
  XCTAssertEqual(operation.isFinished, NO);
}

- (void)testSetFinished {
  [operation setFinished:YES];
  XCTAssertEqual(operation.isFinished, YES);
}

- (void)testSetExecuting {
  [operation setExecuting:YES];
  XCTAssertEqual(operation.isExecuting, YES);
}

- (void)testCompleteOperationWithPath {
  // Setup
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should call savedPathBlock callback with the save path."];
  operation = [[FLTPHPickerSaveItemToPathOperation alloc] initWithResult:mockResult
                                                          maxImageHeight:nil
                                                           maxImageWidth:nil
                                                     desiredImageQuality:nil
                                                          savedPathBlock:^(NSString *savedPath) {
                                                            XCTAssertEqual(savedPath, @"test");
                                                            [resultExpectation fulfill];
                                                          }];
  // Run
  [operation completeOperationWithPath:@"test"];
  // Verify
  XCTAssertEqual(operation.isFinished, YES);
  XCTAssertEqual(operation.isExecuting, NO);
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testSaveVideo {
  // Setup
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should call savedPathBlock callback."];
  NSItemProvider *mockItemProvider = OCMClassMock([NSItemProvider class]);
  NSURL *mockFileUrl = OCMClassMock([NSURL class]);
  OCMStub([mockFileUrl lastPathComponent]).andReturn(@"filename.txt");
  OCMStub([mockFileUrl path]).andReturn(@"test/filename.txt");
  OCMStub([mockItemProvider hasItemConformingToTypeIdentifier:@"public.movie"]).andReturn(YES);
  OCMStub([mockItemProvider registeredTypeIdentifiers]).andReturn(@[ @"public.movie" ]);
  [OCMStub([mockItemProvider loadFileRepresentationForTypeIdentifier:[OCMArg any]
                                                   completionHandler:[OCMArg any]])
      andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(NSURL *_Nullable videoURL, NSError *_Nullable error);
        [invocation getArgument:&completionHandler atIndex:3];
        completionHandler(mockFileUrl, nil);
      }];
  OCMStub([mockResult itemProvider]).andReturn(mockItemProvider);
  operation = [[FLTPHPickerSaveItemToPathOperation alloc] initWithResult:mockResult
                                                          maxImageHeight:(id)[NSNull null]
                                                           maxImageWidth:(id)[NSNull null]
                                                     desiredImageQuality:(id)[NSNull null]
                                                          savedPathBlock:^(NSString *savedPath) {
                                                            [resultExpectation fulfill];
                                                          }];
  id fileManagerMock = OCMClassMock([NSFileManager class]);
  OCMStub([fileManagerMock defaultManager]).andReturn(fileManagerMock);
  OCMStub([fileManagerMock isReadableFileAtPath:[OCMArg any]]).andReturn(YES);
  // Run
  [operation start];
  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testSaveImageForNonOriginalAsset {
  // Setup
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should call savedPathBlock callback."];
  NSItemProvider *mockItemProvider = OCMClassMock([NSItemProvider class]);
  OCMStub([mockItemProvider hasItemConformingToTypeIdentifier:@"public.image"]).andReturn(YES);
  OCMStub([mockResult itemProvider]).andReturn(mockItemProvider);
  UIImage *mockImage = OCMClassMock([UIImage class]);
  [OCMStub([mockItemProvider loadObjectOfClass:[OCMArg any]
                             completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    void (^completionHandler)(__kindof id<NSItemProviderReading> _Nullable data,
                              NSError *_Nullable error);
    [invocation getArgument:&completionHandler atIndex:3];
    completionHandler(mockImage, nil);
  }];
  operation = OCMPartialMock([[FLTPHPickerSaveItemToPathOperation alloc]
           initWithResult:mockResult
           maxImageHeight:(id)[NSNull null]
            maxImageWidth:(id)[NSNull null]
      desiredImageQuality:(id)[NSNull null]
           savedPathBlock:^(NSString *savedPath) {
             [resultExpectation fulfill];
           }]);
  OCMStub([operation scaledImage:[OCMArg any]
                         maxWidth:[OCMArg any]
                        maxHeight:[OCMArg any]
              isMetadataAvailable:[OCMArg any]])
      .andReturn(mockImage);
  OCMStub([operation getAssetFromPHPickerResult:[OCMArg any]]).andReturn(nil);
  OCMStub([operation saveImageWithPickerInfo:[OCMArg any]
                                       image:[OCMArg any]
                                imageQuality:[OCMArg any]])
      .andReturn(@"test");
  // Run
  [operation start];
  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testSaveImageForOriginalAsset {
  // Setup
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Should call savedPathBlock callback."];
  NSItemProvider *mockItemProvider = OCMClassMock([NSItemProvider class]);
  OCMStub([mockItemProvider hasItemConformingToTypeIdentifier:@"public.image"]).andReturn(YES);
  OCMStub([mockResult itemProvider]).andReturn(mockItemProvider);
  UIImage *mockImage = OCMClassMock([UIImage class]);
  [OCMStub([mockItemProvider loadObjectOfClass:[OCMArg any]
                             completionHandler:[OCMArg any]]) andDo:^(NSInvocation *invocation) {
    void (^completionHandler)(__kindof id<NSItemProviderReading> _Nullable data,
                              NSError *_Nullable error);
    [invocation getArgument:&completionHandler atIndex:3];
    completionHandler(mockImage, nil);
  }];
  operation = OCMPartialMock([[FLTPHPickerSaveItemToPathOperation alloc]
           initWithResult:mockResult
           maxImageHeight:(id)[NSNull null]
            maxImageWidth:(id)[NSNull null]
      desiredImageQuality:(id)[NSNull null]
           savedPathBlock:^(NSString *savedPath) {
             [resultExpectation fulfill];
           }]);
  PHAsset *mockAsset = OCMClassMock([PHAsset class]);
  OCMStub([operation getAssetFromPHPickerResult:[OCMArg any]]).andReturn(mockAsset);
  id imageManagerMock = OCMClassMock([PHImageManager class]);
  OCMStub([imageManagerMock defaultManager]).andReturn(imageManagerMock);
  [OCMStub([imageManagerMock requestImageDataForAsset:[OCMArg any]
                                              options:[OCMArg any]
                                        resultHandler:[OCMArg any]])
      andDo:^(NSInvocation *invocation) {
        void (^completionHandler)(NSData *_Nullable imageData, NSString *_Nullable dataUTI,
                                  UIImageOrientation orientation, NSDictionary *_Nullable info);
        [invocation getArgument:&completionHandler atIndex:4];
        completionHandler(nil, nil, UIImageOrientationUp, nil);
      }];
  OCMStub([operation saveImageWithOriginalImageData:[OCMArg any]
                                              image:[OCMArg any]
                                           maxWidth:[OCMArg any]
                                          maxHeight:[OCMArg any]
                                       imageQuality:[OCMArg any]])
      .andReturn(@"test");
  // Run
  [operation start];
  // Verify
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

@end
