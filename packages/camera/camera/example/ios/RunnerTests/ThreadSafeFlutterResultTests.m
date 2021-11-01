// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera;
@import XCTest;

@interface ThreadSafeFlutterResultTests : XCTestCase
@end

@implementation ThreadSafeFlutterResultTests
- (void)testAsyncSendSuccess_ShouldCallResultOnMainThread {
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssert(NSThread.isMainThread);
        [expectation fulfill];
      }];
  dispatch_queue_t dispatchQueue = dispatch_queue_create("test dispatchqueue", NULL);
  dispatch_async(dispatchQueue, ^{
    [threadSafeFlutterResult sendSuccess];
  });

  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}

- (void)testSyncSendSuccess_ShouldCallResultOnMainThread {
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssert(NSThread.isMainThread);
        [expectation fulfill];
      }];
  [threadSafeFlutterResult sendSuccess];
  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}

- (void)testSendNotImplemented_ShouldSendNotImplementedToFlutterResult {
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssert([result isKindOfClass:FlutterMethodNotImplemented.class]);
        [expectation fulfill];
      }];
  dispatch_queue_t dispatchQueue = dispatch_queue_create("test dispatchqueue", NULL);
  dispatch_async(dispatchQueue, ^{
    [threadSafeFlutterResult sendNotImplemented];
  });

  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}

- (void)testSendErrorDetails_ShouldSendErrorToFlutterResult {
  NSString* errorCode = @"errorCode";
  NSString* errorMessage = @"message";
  NSString* errorDetails = @"error details";
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssert([result isKindOfClass:FlutterError.class]);
        FlutterError* error = (FlutterError*)result;
        XCTAssertEqualObjects(error.code, errorCode);
        XCTAssertEqualObjects(error.message, errorMessage);
        XCTAssertEqualObjects(error.details, errorDetails);
        [expectation fulfill];
      }];
  dispatch_queue_t dispatchQueue = dispatch_queue_create("test dispatchqueue", NULL);
  dispatch_async(dispatchQueue, ^{
    [threadSafeFlutterResult sendErrorWithCode:errorCode message:errorMessage details:errorDetails];
  });

  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}

- (void)testSendNSError_ShouldSendErrorToFlutterResult {
  NSError* originalError = [[NSError alloc] initWithDomain:NSURLErrorDomain code:404 userInfo:nil];
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssert([result isKindOfClass:FlutterError.class]);
        FlutterError* error = (FlutterError*)result;
        NSString* constructedErrorCode =
            [NSString stringWithFormat:@"Error %d", (int)originalError.code];
        XCTAssertEqualObjects(error.code, constructedErrorCode);
        [expectation fulfill];
      }];
  dispatch_queue_t dispatchQueue = dispatch_queue_create("test dispatchqueue", NULL);
  dispatch_async(dispatchQueue, ^{
    [threadSafeFlutterResult sendError:originalError];
  });

  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}

- (void)testSendResult_ShouldSendResultToFlutterResult {
  NSString* resultData = @"resultData";
  XCTestExpectation* expectation =
      [[XCTestExpectation alloc] initWithDescription:@"Result finished"];

  FLTThreadSafeFlutterResult* threadSafeFlutterResult =
      [[FLTThreadSafeFlutterResult alloc] initWithResult:^(id _Nullable result) {
        XCTAssertEqualObjects(result, resultData);
        [expectation fulfill];
      }];
  dispatch_queue_t dispatchQueue = dispatch_queue_create("test dispatchqueue", NULL);
  dispatch_async(dispatchQueue, ^{
    [threadSafeFlutterResult sendSuccessWithData:resultData];
  });

  [self waitForExpectations:[NSArray arrayWithObject:expectation] timeout:1];
}
@end
