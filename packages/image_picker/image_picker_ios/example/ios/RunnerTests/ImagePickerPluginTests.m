// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ImagePickerTestImages.h"

@import image_picker_ios;
@import image_picker_ios.Test;
@import XCTest;
#import <OCMock/OCMock.h>

@interface MockViewController : UIViewController
@property(nonatomic, retain) UIViewController *mockPresented;
@end

@implementation MockViewController
@synthesize mockPresented;

- (UIViewController *)presentedViewController {
  return mockPresented;
}

@end

@interface ImagePickerPluginTests : XCTestCase

@end

@implementation ImagePickerPluginTests

- (void)testPluginPickRecentImages {
  XCTestExpectation *pickExpectation = [self expectationWithDescription:@"Picking completed"];

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  PHAsset *mockAsset = OCMClassMock([PHAsset class]);
  NSArray<PHAsset *> *assets = @[ mockAsset, mockAsset, mockAsset ];
  PHFetchResult *mockFetchResult = OCMClassMock([PHFetchResult class]);
  OCMStub([mockFetchResult objectsAtIndexes:[OCMArg any]]).andReturn(assets);
  id phAssetMock = OCMClassMock([PHAsset class]);
  OCMStub([phAssetMock fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[OCMArg any]])
      .andReturn(mockFetchResult);
  id operationFactory = OCMClassMock([FLTPHPickerSaveItemToPathOperationFactory class]);
  __block int operationIndex = 0;
  NSMutableArray<NSOperation *> *operations = [[NSMutableArray alloc] init];
  OCMStub(ClassMethod([operationFactory operationWithAsset:[OCMArg any]
                                            maxImageHeight:[OCMArg any]
                                             maxImageWidth:[OCMArg any]
                                       desiredImageQuality:[OCMArg any]
                                            savedPathBlock:[OCMArg any]]))
      .andDo(^(NSInvocation *invocation) {
        int _operationIndex = operationIndex;
        void (^savedPathBlock)(NSString *savedPath);
        [invocation getArgument:&savedPathBlock atIndex:6];
        FLTPHPickerSaveItemToPathOperation *actualOperation =
            [[FLTPHPickerSaveItemToPathOperation alloc] initWithAsset:mockAsset
                                                       maxImageHeight:nil
                                                        maxImageWidth:nil
                                                  desiredImageQuality:nil
                                                       savedPathBlock:savedPathBlock];
        operations[_operationIndex] = actualOperation;
        FLTPHPickerSaveItemToPathOperation *mockOperation = OCMPartialMock(actualOperation);
        OCMStub([mockOperation start]).andDo(^(NSInvocation *invocation) {
          [mockOperation setExecuting:TRUE];
          [mockOperation completeOperationWithPath:([NSString stringWithFormat:@"/testFile%d.jpg",
                                                                               _operationIndex])];
        });
        [invocation setReturnValue:&actualOperation];
        operationIndex++;
      });

  [plugin pickRecentMediaWithType:[FLTIOSRetrieveTypeData makeWithValue:FLTIOSRetrieveTypeImage]
                          maxSize:[FLTMaxSize makeWithWidth:nil height:nil]
                          quality:nil
                            limit:@3
                       completion:^(NSArray<NSString *> *_Nullable paths,
                                    FlutterError *_Nullable error) {
                         NSArray *expectedPaths =
                             @[ @"/testFile0.jpg", @"/testFile1.jpg", @"/testFile2.jpg" ];
                         XCTAssertEqualObjects(paths, expectedPaths);
                         [pickExpectation fulfill];
                       }];

  [self waitForExpectations:@[ pickExpectation ] timeout:30];
  OCMVerify([phAssetMock fetchAssetsWithMediaType:PHAssetMediaTypeImage options:[OCMArg any]]);
}

- (void)testPluginPickRecentVideos {
  XCTestExpectation *pickExpectation = [self expectationWithDescription:@"Picking completed"];

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  PHAsset *mockAsset = OCMClassMock([PHAsset class]);
  NSArray<PHAsset *> *assets = @[ mockAsset, mockAsset, mockAsset ];
  PHFetchResult *mockFetchResult = OCMClassMock([PHFetchResult class]);
  OCMStub([mockFetchResult objectsAtIndexes:[OCMArg any]]).andReturn(assets);
  id phAssetMock = OCMClassMock([PHAsset class]);
  OCMStub([phAssetMock fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:[OCMArg any]])
      .andReturn(mockFetchResult);
  id operationFactory = OCMClassMock([FLTPHPickerSaveItemToPathOperationFactory class]);
  __block int operationIndex = 0;
  NSMutableArray<NSOperation *> *operations = [[NSMutableArray alloc] init];
  OCMStub(ClassMethod([operationFactory operationWithAsset:[OCMArg any]
                                            maxImageHeight:[OCMArg any]
                                             maxImageWidth:[OCMArg any]
                                       desiredImageQuality:[OCMArg any]
                                            savedPathBlock:[OCMArg any]]))
      .andDo(^(NSInvocation *invocation) {
        int _operationIndex = operationIndex;
        void (^savedPathBlock)(NSString *savedPath);
        [invocation getArgument:&savedPathBlock atIndex:6];
        FLTPHPickerSaveItemToPathOperation *actualOperation =
            [[FLTPHPickerSaveItemToPathOperation alloc] initWithAsset:mockAsset
                                                       maxImageHeight:nil
                                                        maxImageWidth:nil
                                                  desiredImageQuality:nil
                                                       savedPathBlock:savedPathBlock];
        operations[_operationIndex] = actualOperation;
        FLTPHPickerSaveItemToPathOperation *mockOperation = OCMPartialMock(actualOperation);
        OCMStub([mockOperation start]).andDo(^(NSInvocation *invocation) {
          [mockOperation setExecuting:TRUE];
          [mockOperation completeOperationWithPath:([NSString stringWithFormat:@"/testFile%d.mp4",
                                                                               _operationIndex])];
        });
        [invocation setReturnValue:&actualOperation];
        operationIndex++;
      });

  [plugin pickRecentMediaWithType:[FLTIOSRetrieveTypeData makeWithValue:FLTIOSRetrieveTypeVideo]
                          maxSize:[FLTMaxSize makeWithWidth:nil height:nil]
                          quality:nil
                            limit:@3
                       completion:^(NSArray<NSString *> *_Nullable paths,
                                    FlutterError *_Nullable error) {
                         NSArray *expectedPaths =
                             @[ @"/testFile0.mp4", @"/testFile1.mp4", @"/testFile2.mp4" ];
                         XCTAssertEqualObjects(paths, expectedPaths);
                         [pickExpectation fulfill];
                       }];

  [self waitForExpectations:@[ pickExpectation ] timeout:30];
  OCMVerify([phAssetMock fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:[OCMArg any]]);
}

- (void)testPluginPickImageDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickImageDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraFront]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPluginPickVideoDeviceBack {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);
  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceRear is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                  maxDuration:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceRear);
}

- (void)testPluginPickVideoDeviceFront {
  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id mockAVCaptureDevice = OCMClassMock([AVCaptureDevice class]);

  // UIImagePickerControllerSourceTypeCamera is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]))
      .andReturn(YES);

  // UIImagePickerControllerCameraDeviceFront is supported
  OCMStub(ClassMethod(
              [mockUIImagePicker isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]))
      .andReturn(YES);

  // AVAuthorizationStatusAuthorized is supported
  OCMStub([mockAVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
      .andReturn(AVAuthorizationStatusAuthorized);

  // Run test
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraFront]
                  maxDuration:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.cameraDevice, UIImagePickerControllerCameraDeviceFront);
}

- (void)testPickMultiImageShouldUseUIImagePickerControllerOnPreiOS14 {
  if (@available(iOS 14, *)) {
    return;
  }

  id mockUIImagePicker = OCMClassMock([UIImagePickerController class]);
  id photoLibrary = OCMClassMock([PHPhotoLibrary class]);
  OCMStub(ClassMethod([photoLibrary authorizationStatus]))
      .andReturn(PHAuthorizationStatusAuthorized);

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  [plugin setImagePickerControllerOverrides:@[ mockUIImagePicker ]];

  [plugin pickMultiImageWithMaxSize:[FLTMaxSize makeWithWidth:@(100) height:@(200)]
                            quality:@(50)
                         completion:^(NSArray<NSString *> *_Nullable result,
                                      FlutterError *_Nullable error){
                         }];
  OCMVerify(times(1),
            [mockUIImagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary]);
}

#pragma mark - Test camera devices, no op on simulators

- (void)testPluginPickImageDeviceCancelClickMultipleTimes {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    return;
  }
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  plugin.imagePickerControllerOverrides = @[ controller ];

  [plugin pickImageWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                      maxSize:[[FLTMaxSize alloc] init]
                      quality:nil
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  // To ensure the flow does not crash by multiple cancel call
  [plugin imagePickerControllerDidCancel:controller];
  [plugin imagePickerControllerDidCancel:controller];
}

#pragma mark - Test video duration

- (void)testPickingVideoWithDuration {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  UIImagePickerController *controller = [[UIImagePickerController alloc] init];
  [plugin setImagePickerControllerOverrides:@[ controller ]];

  [plugin pickVideoWithSource:[FLTSourceSpecification makeWithType:FLTSourceTypeCamera
                                                            camera:FLTSourceCameraRear]
                  maxDuration:@(95)
                   completion:^(NSString *_Nullable result, FlutterError *_Nullable error){
                   }];

  XCTAssertEqual(controller.videoMaximumDuration, 95);
}

- (void)testViewController {
  UIWindow *window = [UIWindow new];
  MockViewController *vc1 = [MockViewController new];
  window.rootViewController = vc1;

  UIViewController *vc2 = [UIViewController new];
  vc1.mockPresented = vc2;

  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  XCTAssertEqual([plugin viewControllerWithWindow:window], vc2);
}

- (void)testPluginMultiImagePathHasNullItem {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];

  dispatch_semaphore_t resultSemaphore = dispatch_semaphore_create(0);
  __block FlutterError *pickImageResult = nil;
  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        pickImageResult = error;
        dispatch_semaphore_signal(resultSemaphore);
      }];
  [plugin sendCallResultWithSavedPathList:@[ [NSNull null] ]];

  dispatch_semaphore_wait(resultSemaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqualObjects(pickImageResult.code, @"create_error");
}

- (void)testPluginMultiImagePathHasItem {
  FLTImagePickerPlugin *plugin = [FLTImagePickerPlugin new];
  NSArray *pathList = @[ @"test" ];

  dispatch_semaphore_t resultSemaphore = dispatch_semaphore_create(0);
  __block id pickImageResult = nil;

  plugin.callContext = [[FLTImagePickerMethodCallContext alloc]
      initWithResult:^(NSArray<NSString *> *_Nullable result, FlutterError *_Nullable error) {
        pickImageResult = result;
        dispatch_semaphore_signal(resultSemaphore);
      }];
  [plugin sendCallResultWithSavedPathList:pathList];

  dispatch_semaphore_wait(resultSemaphore, DISPATCH_TIME_FOREVER);

  XCTAssertEqual(pickImageResult, pathList);
}

@end
