// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import video_player;
@import XCTest;

@interface VideoPlayerTests : XCTestCase
@end

@implementation VideoPlayerTests

- (void)testPlugin {
  FLTVideoPlayerPlugin* plugin = [[FLTVideoPlayerPlugin alloc] init];
  XCTAssertNotNil(plugin);
}

@end
