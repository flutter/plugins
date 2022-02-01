//
//  FLTSavePhotoDelegateTests.m
//  RunnerTests
//
//  Created by Huan Lin on 1/31/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

@import camera;
@import camera.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>

@interface FLTSavePhotoDelegate : NSObject <AVCapturePhotoCaptureDelegate>
@property(readonly, nonatomic) NSString *path;
- initWithPath:(NSString *)path
        result:(FLTThreadSafeFlutterResult *)result
       ioQueue:(dispatch_queue_t)ioQueue;
- (void)handlePhotoCaptureResultWithError:(nullable NSError *)error
                        photoDataProvider:(NSData * (^)(void))photoDataProvider;
@end

@interface FLTSavePhotoDelegateTests : XCTestCase

@end

@implementation FLTSavePhotoDelegateTests

- (void)testHandlePhotoCaptureResult_mustSendErrorIfFailedToCapture {
  NSError *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];
  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc] initWithPath:@"test"
                                                                       result:mockResult
                                                                      ioQueue:ioQueue];

  [delegate handlePhotoCaptureResultWithError:error
                            photoDataProvider:^NSData * {
                              return nil;
                            }];
  OCMVerify(times(1), [mockResult sendError:error]);
}

- (void)testHandlePhotoCaptureResult_mustSendErrorIfFailedToWrite {
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Must send IOError to the result if failed to write file."];
  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  OCMStub([mockResult sendErrorWithCode:@"IOError" message:@"Unable to write file" details:nil])
      .andDo(^(NSInvocation *invocation) {
        [resultExpectation fulfill];
      });
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc] initWithPath:@"test"
                                                                       result:mockResult
                                                                      ioQueue:ioQueue];

  // We can't use OCMClassMock for NSData because some XCTest APIs uses NSData (e.g.
  // `XCTRunnerIDESession::logDebugMessage:`) on a private queue.
  id mockData = OCMPartialMock([NSData data]);
  OCMStub([mockData writeToFile:[OCMArg any] atomically:[OCMArg any]]).andReturn(NO);
  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^NSData * {
                              return mockData;
                            }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandlePhotoCaptureResult_mustSendSuccessIfSuccessToWrite {
  XCTestExpectation *resultExpectation = [self
      expectationWithDescription:@"Must send file path to the result if success to write file."];

  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc] initWithPath:@"test"
                                                                       result:mockResult
                                                                      ioQueue:ioQueue];
  OCMStub([mockResult sendSuccessWithData:delegate.path]).andDo(^(NSInvocation *invocation) {
    [resultExpectation fulfill];
  });

  // We can't use OCMClassMock for NSData because some XCTest APIs uses NSData (e.g.
  // `XCTRunnerIDESession::logDebugMessage:`) on a private queue.
  id mockData = OCMPartialMock([NSData data]);
  OCMStub([mockData writeToFile:[OCMArg any] atomically:[OCMArg any]]).andReturn(YES);

  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^NSData * {
                              return mockData;
                            }];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testHandlePhotoCaptureResult_bothProvideDataAndSaveFileMustRunOnIOQueue {
  XCTestExpectation *dataProviderQueueExpectation =
      [self expectationWithDescription:@"Data provider must run on io queue."];
  XCTestExpectation *writeFileQueueExpectation =
      [self expectationWithDescription:@"File writing must run on io queue"];
  XCTestExpectation *resultExpectation = [self
      expectationWithDescription:@"Must send file path to the result if success to write file."];

  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  const char *ioQueueSpecific = "io_queue_specific";
  dispatch_queue_set_specific(ioQueue, ioQueueSpecific, (void *)ioQueueSpecific, NULL);
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);
  OCMStub([mockResult sendSuccessWithData:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
    [resultExpectation fulfill];
  });

  // We can't use OCMClassMock for NSData because some XCTest APIs uses NSData (e.g.
  // `XCTRunnerIDESession::logDebugMessage:`) on a private queue.
  id mockData = OCMPartialMock([NSData data]);
  OCMStub([mockData writeToFile:[OCMArg any] atomically:[OCMArg any]])
      .andDo(^(NSInvocation *invocation) {
        if (dispatch_get_specific(ioQueueSpecific)) {
          [writeFileQueueExpectation fulfill];
        }
      })
      .andReturn(YES);

  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc] initWithPath:@"test"
                                                                       result:mockResult
                                                                      ioQueue:ioQueue];
  [delegate handlePhotoCaptureResultWithError:nil
                            photoDataProvider:^NSData * {
                              if (dispatch_get_specific(ioQueueSpecific)) {
                                [dataProviderQueueExpectation fulfill];
                              }
                              return mockData;
                            }];

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
