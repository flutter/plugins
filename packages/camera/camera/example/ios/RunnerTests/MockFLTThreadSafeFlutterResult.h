// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef MockFLTThreadSafeFlutterResult_h
#define MockFLTThreadSafeFlutterResult_h

@interface FLTThreadSafeFlutterResult ()
@property(readonly, nonatomic) FlutterResult _Nonnull flutterResult;
@end

/**
 * Extends FLTThreadSafeFlutterResult to give tests the ability to wait on the result and
 * read the received result.
 */
@interface MockFLTThreadSafeFlutterResult : FLTThreadSafeFlutterResult
@property(readonly, nonatomic) XCTestExpectation *_Nonnull expectation;
@property(nonatomic, nullable) id receivedResult;

- (id _Nonnull)initWithExpectation:(XCTestExpectation *_Nonnull)expectation;
@end

#endif /* MockFLTThreadSafeFlutterResult_h */
