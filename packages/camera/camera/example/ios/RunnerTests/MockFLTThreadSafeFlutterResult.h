//
//  MockFLTThreadSafeFlutterResult.h
//  Runner
//
//  Created by Maurits van Beusekom on 11/10/2021.
//  Copyright © 2021 The Flutter Authors. All rights reserved.
//

#ifndef MockFLTThreadSafeFlutterResult_h
#define MockFLTThreadSafeFlutterResult_h

@interface FLTThreadSafeFlutterResult ()
@property(readonly, nonatomic) FlutterResult flutterResult;
@end

/**
 * Extends FLTThreadSafeFlutterResult to give tests the ability to wait on the result and
 * read the received result.
 */
@interface MockFLTThreadSafeFlutterResult : FLTThreadSafeFlutterResult
@property(readonly, nonatomic) XCTestExpectation *expectation;
@property(nonatomic, nullable) id receivedResult;

-(id)initWithExpectation:(XCTestExpectation *)expectation;
@end

#endif /* MockFLTThreadSafeFlutterResult_h */
