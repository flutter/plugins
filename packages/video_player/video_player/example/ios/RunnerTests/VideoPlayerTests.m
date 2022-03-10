// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import AVFoundation;
@import video_player;
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


- (void)testSetMixWithOthersForPlayer {
    FLTVideoPlayerPlugin* videoPlayer = [[FLTVideoPlayerPlugin alloc] init];
    FLTMixWithOthersMessage* msg = [[FLTMixWithOthersMessage alloc] init];
    AVAudioSession* session = [AVAudioSession sharedInstance];
    FlutterError *error;

    [videoPlayer initialize:&error];

    msg.mixWithOthers = @0;
    msg.ambient = @0;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryPlayback);
    XCTAssertNotEqual(session.mode, AVAudioSessionModeVoicePrompt);

    msg.mixWithOthers = @1;
    msg.ambient = @0;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryPlayback);
    XCTAssertEqual(session.categoryOptions, AVAudioSessionCategoryOptionMixWithOthers);

    msg.mixWithOthers = @1;
    msg.ambient = @1;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryAmbient);
    XCTAssertEqual(session.categoryOptions, AVAudioSessionCategoryOptionMixWithOthers);
    XCTAssertEqual(session.mode, AVAudioSessionModeVoicePrompt);

    msg.mixWithOthers = @0;
    msg.ambient = @1;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryAmbient);
    XCTAssertEqual(session.mode, AVAudioSessionModeVoicePrompt);

    msg.mixWithOthers = @1;
    msg.ambient = @0;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryPlayback);
    XCTAssertEqual(session.categoryOptions, AVAudioSessionCategoryOptionMixWithOthers);
    XCTAssertNotEqual(session.mode, AVAudioSessionModeVoicePrompt);

    msg.mixWithOthers = @0;
    msg.ambient = @0;
    [videoPlayer setMixWithOthers:msg error:&error];

    XCTAssertEqual(session.category, AVAudioSessionCategoryPlayback);
    XCTAssertNotEqual(session.mode, AVAudioSessionModeVoicePrompt);
}



@end
