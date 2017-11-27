// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <AVFoundation/AVFoundation.h>
#import "VideoPlayerPlugin.h"

int64_t CMTimeToMillis(CMTime time) {
    return time.value * 1000 / time.timescale;
}

@interface FrameUpdater : NSObject
@property(nonatomic) int64_t textureId;
@property(nonatomic, readonly) NSObject<FlutterTextureRegistry>* registry;
- (void)onDisplayLink:(CADisplayLink*)link;
@end

@implementation FrameUpdater
- (FrameUpdater*)initWithRegistry:(NSObject<FlutterTextureRegistry>*)registry {
  NSAssert(self, @"super init cannot be nil");
  if (self == nil) return nil;
  _registry = registry;
  return self;
}

- (void)onDisplayLink:(CADisplayLink*)link {
  [_registry textureFrameAvailable:_textureId];
}
@end

@interface VideoPlayer : NSObject<FlutterTexture, FlutterStreamHandler>
@property(readonly, nonatomic) AVPlayer* player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput* videoOutput;
@property(readonly, nonatomic) CADisplayLink* displayLink;
@property(nonatomic) FlutterEventChannel* eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(nonatomic, readonly) bool disposed;
@property(nonatomic, readonly) bool isPlaying;
@property(nonatomic, readonly) bool isLooping;
@property(nonatomic, readonly) bool isInitialized;
- (instancetype)initWithURL:(NSURL*)url
               frameUpdater:(FrameUpdater*)frameUpdater;
- (void)play;
- (void)pause;
- (void)setIsLooping:(bool)isLooping;
- (void)updatePlayingState;
@end

static void *timeRangeContext = &timeRangeContext;
static void *statusContext = &statusContext;
static void *playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext;

@implementation VideoPlayer
- (instancetype)initWithURL:(NSURL*)url
               frameUpdater:(FrameUpdater*)frameUpdater {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _isInitialized = false;
  _isPlaying = false;
  _disposed = false;
  _player = [[AVPlayer alloc] init];
  _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
  [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:[_player currentItem]
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *note) {
    if (_isLooping) {
      AVPlayerItem *p = [note object];
      [p seekToTime:kCMTimeZero];
    } else {
        if (_eventSink) {
            _eventSink(@{@"event":@"completed"});
        }
    }
  }];
  NSDictionary *pixBuffAttributes = @{
    (id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferIOSurfacePropertiesKey:@{}
  };
  _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
  AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
  [item addObserver:self
         forKeyPath:@"loadedTimeRanges"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:timeRangeContext];
  [item addObserver:self
         forKeyPath:@"status"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:statusContext];
  [item addObserver:self
         forKeyPath:@"playbackLikelyToKeepUp"
            options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
            context:playbackLikelyToKeepUpContext];

  AVAsset *asset = [item asset];

  [asset loadValuesAsynchronouslyForKeys:@[@"tracks"] completionHandler:^{
      if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
          NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
          if ([tracks count] > 0) {
              AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
              [videoTrack loadValuesAsynchronouslyForKeys:@[@"preferredTransform"] completionHandler:^{
                if (_disposed) return;
                if ([videoTrack statusOfValueForKey:@"preferredTransform" error:nil] == AVKeyValueStatusLoaded) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [item addOutput:_videoOutput];
                          [_player replaceCurrentItemWithPlayerItem:item];
                      });
                  }
              }];
          }
      }
  }];
  _displayLink = [CADisplayLink displayLinkWithTarget:frameUpdater selector:@selector(onDisplayLink:)];
  [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  _displayLink.paused = YES;
  return self;
}

- (void)observeValueForKeyPath:(NSString*)path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context {
    if (context == timeRangeContext) {
        if (_eventSink != nil) {
            NSMutableArray<NSArray<NSNumber*>*>* values = [[NSMutableArray alloc] init];
            for (NSValue* rangeValue in [object loadedTimeRanges]) {
                CMTimeRange range = [rangeValue CMTimeRangeValue];
                int64_t start = CMTimeToMillis(range.start);
                [values addObject:@[@(start), @(start + CMTimeToMillis(range.duration))]];
            }
            _eventSink(@{@"event":@"bufferingUpdate", @"values":values});
        }
    } else if (context == statusContext) {
        if (_eventSink != nil) {
            AVPlayerItem* item = (AVPlayerItem*)object;
            switch(item.status) {
                case AVPlayerStatusFailed:
                    _eventSink([FlutterError errorWithCode:@"VideoError" message:[@"Failed to load video: " stringByAppendingString:[item.error localizedDescription]] details:nil]);
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    _isInitialized = true;
                    [self sendInitialized];
                    [self updatePlayingState];
                    break;
            }
        }
    } else if (context == playbackLikelyToKeepUpContext) {
        if ([[_player currentItem] isPlaybackLikelyToKeepUp]) {
            [self updatePlayingState];
        }
    }
}

- (void)updatePlayingState {
    if (!_isInitialized) {
        return;
    }
    if (_isPlaying) {
        [_player play];
    } else {
        [_player pause];
    }
    _displayLink.paused = !_isPlaying;
}

- (void)sendInitialized {
    if (_eventSink && _isInitialized) {
      _eventSink(@{@"event":@"initialized", @"duration":@([self duration])});
    }
}

- (void)play {
    _isPlaying = true;
    [self updatePlayingState];
}

- (void)pause {
  _isPlaying = false;
  [self updatePlayingState];
}

- (int64_t)position {
    return CMTimeToMillis([_player currentTime]);
}

- (int64_t)duration {
    return CMTimeToMillis([[_player currentItem] duration]);
}

- (void)seekTo:(int)location {
    [_player seekToTime:CMTimeMake(location, 1000)];
}

- (void)setIsLooping:(bool)isLooping {
    _isLooping = isLooping;
}

- (void)setVolume:(double)volume {
    _player.volume = (volume < 0.0) ? 0.0 : ((volume > 1.0) ? 1.0 : volume);
}

- (CVPixelBufferRef)copyPixelBuffer {
  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
      return [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
  } else {
    return NULL;
  }
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    [self sendInitialized];
    return nil;
}

- (void)dispose {
    _disposed = true;
    [[_player currentItem] removeObserver:self forKeyPath:@"status" context:statusContext];
    [[_player currentItem] removeObserver:self forKeyPath:@"loadedTimeRanges" context:timeRangeContext];
    [[_player currentItem] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:playbackLikelyToKeepUpContext];
    [_player replaceCurrentItemWithPlayerItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_eventChannel setStreamHandler:nil];
}

@end

@interface VideoPlayerPlugin ()
@property(readonly, nonatomic) NSObject<FlutterTextureRegistry>* registry;
@property(readonly, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@property(readonly, nonatomic) NSMutableDictionary* players;
@end

@implementation VideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter.io/videoPlayer"
            binaryMessenger:[registrar messenger]];
  VideoPlayerPlugin* instance = [[VideoPlayerPlugin alloc] initWithRegistry:[registrar textures]
                                                                  messenger:[registrar messenger]];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistry:(NSObject<FlutterTextureRegistry>*)registry
                       messenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = registry;
  _messenger = messenger;
  _players = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    for (NSNumber* textureId in _players) {
        [_registry unregisterTexture:[textureId unsignedIntegerValue]];
        [[_players objectForKey:textureId] dispose];
    }
    [_players removeAllObjects];
  } else if ([@"create" isEqualToString:call.method]) {
    NSDictionary* argsMap = call.arguments;
    NSString* dataSource = argsMap[@"dataSource"];
    FrameUpdater* frameUpdater =
        [[FrameUpdater alloc] initWithRegistry:_registry];
      VideoPlayer* player =
        [[VideoPlayer alloc] initWithURL:[NSURL URLWithString:dataSource]
                            frameUpdater:frameUpdater];
    int64_t textureId = [_registry registerTexture:player];
    frameUpdater.textureId = textureId;
    FlutterEventChannel* eventChannel =
        [FlutterEventChannel
         eventChannelWithName:[NSString stringWithFormat:@"flutter.io/videoPlayer/videoEvents%lld", textureId]
              binaryMessenger:_messenger];
    [eventChannel setStreamHandler:player];
    player.eventChannel = eventChannel;
    _players[@(textureId)] = player;
    result(@{@"textureId":@(textureId)});
  } else {
    NSDictionary* argsMap = call.arguments;
    int64_t textureId = ((NSNumber*) argsMap[@"textureId"]).unsignedIntegerValue;
    VideoPlayer* player = _players[@(textureId)];
    if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:textureId];
      [_players removeObjectForKey:@(textureId)];
      [player dispose];
    } else if ([@"setLooping" isEqualToString:call.method]) {
        [player setIsLooping:[argsMap objectForKey:@"looping"]];
        result(nil);
    } else if ([@"setVolume" isEqualToString:call.method]) {
        [player setVolume:[[argsMap objectForKey:@"volume"] doubleValue]];
        result(nil);
    } else if ([@"play" isEqualToString:call.method]) {
      [player play];
      result(nil);
    } else if ([@"position" isEqualToString:call.method]) {
      result(@([player position]));
    } else if ([@"seekTo" isEqualToString:call.method]) {
      [player seekTo:[[argsMap objectForKey:@"location"] intValue]];
      result(nil);
    } else if ([@"pause" isEqualToString:call.method]) {
      [player pause];
      result(nil);
    } else {
      result(FlutterMethodNotImplemented);
    }
  }
}

@end
