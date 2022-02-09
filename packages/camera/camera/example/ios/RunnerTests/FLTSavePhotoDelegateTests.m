// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import camera.Test;
@import AVFoundation;
@import XCTest;
#import <OCMock/OCMock.h>

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
  OCMVerify([mockResult sendError:error]);
}

- (void)testHandlePhotoCaptureResult_mustSendErrorIfFailedToWrite {
  XCTestExpectation *resultExpectation =
      [self expectationWithDescription:@"Must send IOError to the result if failed to write file."];
  dispatch_queue_t ioQueue = dispatch_queue_create("test", NULL);
  id mockResult = OCMClassMock([FLTThreadSafeFlutterResult class]);

  NSError *ioError = [NSError errorWithDomain:@"IOError"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : @"Localized IO Error"}];

  OCMStub([mockResult sendErrorWithCode:@"IOError"
                                message:@"Unable to write file"
                                details:ioError.localizedDescription])
      .andDo(^(NSInvocation *invocation) {
        [resultExpectation fulfill];
      });
  FLTSavePhotoDelegate *delegate = [[FLTSavePhotoDelegate alloc] initWithPath:@"test"
                                                                       result:mockResult
                                                                      ioQueue:ioQueue];

  // We can't use OCMClassMock for NSData because some XCTest APIs uses NSData (e.g.
  // `XCTRunnerIDESession::logDebugMessage:`) on a private queue.
  id mockData = OCMPartialMock([NSData data]);
  OCMStub([mockData writeToFile:OCMOCK_ANY
                        options:NSDataWritingAtomic
                          error:[OCMArg setTo:ioError]])
      .andReturn(NO);
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
  OCMStub([mockData writeToFile:OCMOCK_ANY options:NSDataWritingAtomic error:[OCMArg setTo:nil]])
      .andReturn(YES);

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
  OCMStub([mockResult sendSuccessWithData:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
    [resultExpectation fulfill];
  });

  // We can't use OCMClassMock for NSData because some XCTest APIs uses NSData (e.g.
  // `XCTRunnerIDESession::logDebugMessage:`) on a private queue.
  id mockData = OCMPartialMock([NSData data]);
  OCMStub([mockData writeToFile:OCMOCK_ANY options:NSDataWritingAtomic error:[OCMArg setTo:nil]])
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
