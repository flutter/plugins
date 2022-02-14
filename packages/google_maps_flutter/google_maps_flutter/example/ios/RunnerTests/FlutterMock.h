//
//  FlutterMock.h
//  RunnerTests
//
//  Created by Guy Kogus on 14/2/22.
//  Copyright © 2022 The Flutter Authors. All rights reserved.
//

@import Foundation;
@import Flutter;

NS_ASSUME_NONNULL_BEGIN

@interface MockRegistrar : NSObject<FlutterPluginRegistrar>
@end

@interface MockBinaryMessenger : NSObject<FlutterBinaryMessenger>
@end

@interface MockTextureRegistry : NSObject<FlutterTextureRegistry>
@end

NS_ASSUME_NONNULL_END
