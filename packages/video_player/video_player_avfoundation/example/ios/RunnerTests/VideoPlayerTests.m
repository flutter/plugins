// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player_avfoundation;
@import XCTest;

#import <OCMock/OCMock.h>

@interface FLTVideoPlayer : NSObject <FlutterStreamHandler>
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
  FLTPositionMessage *message = [FLTPositionMessage makeWithTextureId:@101 position:@0];
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

  FLTCreateMessage *create = [FLTCreateMessage
      makeWithAsset:nil
                uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"
        packageName:nil
         formatHint:nil
        httpHeaders:@{}];
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
  [self waitForExpectationsWithTimeout:30.0 handler:nil];
}

- (void)testVideoControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestVideoControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *videoInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"];
  XCTAssertEqualObjects(videoInitialization[@"height"], @720);
  XCTAssertEqualObjects(videoInitialization[@"width"], @1280);
  XCTAssertEqualWithAccuracy([videoInitialization[@"duration"] intValue], 4000, 200);
}

- (void)testAudioControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestAudioControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *audioInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/audio/rooster.mp3"];
  XCTAssertEqualObjects(audioInitialization[@"height"], @0);
  XCTAssertEqualObjects(audioInitialization[@"width"], @0);
  // Perfect precision not guaranteed.
  XCTAssertEqualWithAccuracy([audioInitialization[@"duration"] intValue], 5400, 200);
}

- (void)testHLSControls {
  NSObject<FlutterPluginRegistry> *registry =
      (NSObject<FlutterPluginRegistry> *)[[UIApplication sharedApplication] delegate];
  NSObject<FlutterPluginRegistrar> *registrar = [registry registrarForPlugin:@"TestHLSControls"];

  FLTVideoPlayerPlugin *videoPlayerPlugin =
      (FLTVideoPlayerPlugin *)[[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];

  NSDictionary<NSString *, id> *videoInitialization =
      [self testPlugin:videoPlayerPlugin
                   uri:@"https://flutter.github.io/assets-for-api-docs/assets/videos/hls/bee.m3u8"];
  XCTAssertEqualObjects(videoInitialization[@"height"], @720);
  XCTAssertEqualObjects(videoInitialization[@"width"], @1280);
  XCTAssertEqualWithAccuracy([videoInitialization[@"duration"] intValue], 4000, 200);
}

- (NSDictionary<NSString *, id> *)testPlugin:(FLTVideoPlayerPlugin *)videoPlayerPlugin
                                         uri:(NSString *)uri {
  FlutterError *error;
  [videoPlayerPlugin initialize:&error];
  XCTAssertNil(error);

  FLTCreateMessage *create = [FLTCreateMessage makeWithAsset:nil
                                                         uri:uri
                                                 packageName:nil
                                                  formatHint:nil
                                                 httpHeaders:@{}];
  FLTTextureMessage *textureMessage = [videoPlayerPlugin create:create error:&error];

  NSNumber *textureId = textureMessage.textureId;
  FLTVideoPlayer *player = videoPlayerPlugin.playersByTextureId[textureId];
  XCTAssertNotNil(player);

  XCTestExpectation *initializedExpectation = [self expectationWithDescription:@"initialized"];
  __block NSDictionary<NSString *, id> *initializationEvent;
  [player onListenWithArguments:nil
                      eventSink:^(NSDictionary<NSString *, id> *event) {
                        if ([event[@"event"] isEqualToString:@"initialized"]) {
                          initializationEvent = event;
                          XCTAssertEqual(event.count, 4);
                          [initializedExpectation fulfill];
                        }
                      }];
  [self waitForExpectationsWithTimeout:30.0 handler:nil];

  // Starts paused.
  AVPlayer *avPlayer = player.player;
  XCTAssertEqual(avPlayer.rate, 0);
  XCTAssertEqual(avPlayer.volume, 1);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusPaused);

  // Change playback speed.
  FLTPlaybackSpeedMessage *playback = [FLTPlaybackSpeedMessage makeWithTextureId:textureId
                                                                           speed:@2];
  [videoPlayerPlugin setPlaybackSpeed:playback error:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.rate, 2);
  XCTAssertEqual(avPlayer.timeControlStatus, AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate);

  // Volume
  FLTVolumeMessage *volume = [FLTVolumeMessage makeWithTextureId:textureId volume:@0.1];
  [videoPlayerPlugin setVolume:volume error:&error];
  XCTAssertNil(error);
  XCTAssertEqual(avPlayer.volume, 0.1f);

  [player onCancelWithArguments:nil];

  return initializationEvent;
}

@end
