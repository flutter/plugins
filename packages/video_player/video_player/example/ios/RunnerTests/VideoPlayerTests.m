// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player;
@import XCTest;

#import <OCMock/OCMock.h>

@interface FLTVideoPlayer : NSObject
@property(readonly, nonatomic) AVPlayer *player;
@end

@interface FLTVideoPlayerPlugin (Test) <FLTVideoPlayerApi>
@property(readonly, strong, nonatomic)
    NSMutableDictionary<NSNumber *, FLTVideoPlayer *> *playersByTextureId;
@end

@interface VideoPlayerTests : XCTestCase
@end

@implementation VideoPlayerTests

- (void)testSeekToInvokesTextureFrameAvailableOnTextureRegistry {
  NSObject<FlutterTextureRegistry> *mockTextureRegistry =
      OCMProtocolMock(@protocol(FlutterTextureRegistry));
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"SeekToInvokestextureFrameAvailable"];
  NSObject<FlutterPluginRegistrar> *partialRegistrar = OCMPartialMock(registrar);
  OCMStub([partialRegistrar textures]).andReturn(mockTextureRegistry);
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:partialRegistrar];
  FLTPositionMessage *message = [[FLTPositionMessage alloc] init];
  message.textureId = @101;
  message.position = @0;
  FlutterError *error;
  [videoPlayerPlugin seekTo:message error:&error];
  OCMVerify([mockTextureRegistry textureFrameAvailable:message.textureId.intValue]);
}

- (void)testDeregistersFromPlayer {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar =
      [registry registrarForPlugin:@"testDeregistersFromPlayer"];
  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [[FLTCreateMessage alloc] init];
  create.uri = @"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];
  XCTAssertNil(error);
  XCTAssertNotNil(textureMessage);
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureMessage.textureId];
  XCTAssertNotNil(player);
  AVPlayer *avPlayer = player.player;

  [videoPlayerPlugin dispose:textureMessage error:&error];
  XCTAssertEqual(videoPlayerPlugin.playersByTextureId.count, 0);
  XCTAssertNil(error);

  [self keyValueObservingExpectationForObject:avPlayer keyPath:@"currentItem" expectedValue:nil];
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
