// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTVideoPlayerPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

#if !__has_feature(objc_arc)
#error Code Requires ARC.
#endif

int64_t FLTCMTimeToMillis(CMTime time) {
  if (time.timescale == 0) return 0;
  return time.value * 1000 / time.timescale;
}

@interface FLTFrameUpdater : NSObject
@property(nonatomic) int64_t textureId;
@property(nonatomic, weak, readonly) NSObject<FlutterTextureRegistry>* registry;
- (void)onDisplayLink:(CADisplayLink*)link;
@end

@implementation FLTFrameUpdater
- (FLTFrameUpdater*)initWithRegistry:(NSObject<FlutterTextureRegistry>*)registry {
  NSAssert(self, @"super init cannot be nil");
  if (self == nil) return nil;
  _registry = registry;
  return self;
}

- (void)onDisplayLink:(CADisplayLink*)link {
  [_registry textureFrameAvailable:_textureId];
}
@end

@interface FLTVideoPlayer : NSObject <FlutterTexture, FlutterStreamHandler>
@property(readonly, nonatomic) AVPlayer* player;
@property(readonly, nonatomic) AVPlayerItemVideoOutput* videoOutput;
@property(readonly, nonatomic) CADisplayLink* displayLink;
@property(nonatomic) FlutterEventChannel* eventChannel;
@property(nonatomic) FlutterEventSink eventSink;
@property(nonatomic) CGAffineTransform preferredTransform;
@property(nonatomic, readonly) bool disposed;
@property(nonatomic, readonly) bool isPlaying;
@property(nonatomic) bool isLooping;
@property(nonatomic, readonly) bool isInitialized;
@property(nonatomic, readonly) NSString* key;
@property(nonatomic, readonly) CVPixelBufferRef prevBuffer;
@property(nonatomic, readonly) int failedCount;
- (void)play;
- (void)pause;
- (void)setIsLooping:(bool)isLooping;
- (void)updatePlayingState;
@end

static void* timeRangeContext = &timeRangeContext;
static void* statusContext = &statusContext;
static void* playbackLikelyToKeepUpContext = &playbackLikelyToKeepUpContext;
static void* playbackBufferEmptyContext = &playbackBufferEmptyContext;
static void* playbackBufferFullContext = &playbackBufferFullContext;

@implementation FLTVideoPlayer
- (instancetype)initWithFrameUpdater:(FLTFrameUpdater*)frameUpdater {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _isInitialized = false;
  _isPlaying = false;
  _disposed = false;
  _player = [[AVPlayer alloc] init];
  _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
  _displayLink = [CADisplayLink displayLinkWithTarget:frameUpdater
                                             selector:@selector(onDisplayLink:)];
  [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
  _displayLink.paused = YES;
  return self;
}

- (void)addObservers:(AVPlayerItem*)item {
  [item addObserver:self forKeyPath:@"loadedTimeRanges" options:0 context:timeRangeContext];
  [item addObserver:self forKeyPath:@"status" options:0 context:statusContext];
  [item addObserver:self
         forKeyPath:@"playbackLikelyToKeepUp"
            options:0
            context:playbackLikelyToKeepUpContext];
  [item addObserver:self
         forKeyPath:@"playbackBufferEmpty"
            options:0
            context:playbackBufferEmptyContext];
  [item addObserver:self
         forKeyPath:@"playbackBufferFull"
            options:0
            context:playbackBufferFullContext];

  // Add an observer that will respond to itemDidPlayToEndTime
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(itemDidPlayToEndTime:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:item];
}

- (void)removeVideoOutput {
  _videoOutput = nil;
  if (_player.currentItem == nil) {
    return;
  }
  NSArray<AVPlayerItemOutput*>* outputs = [[_player currentItem] outputs];
  for (AVPlayerItemOutput* output in outputs) {
    [[_player currentItem] removeOutput:output];
  }
}

- (void)clear {
  _displayLink.paused = YES;
  _isInitialized = false;
  _isPlaying = false;
  _disposed = false;
  _videoOutput = nil;
  _failedCount = 0;
  _key = nil;
  if (_player.currentItem == nil) {
    return;
  }

  if (_player.currentItem == nil) {
    return;
  }
  [[_player currentItem] removeObserver:self forKeyPath:@"status" context:statusContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"loadedTimeRanges"
                                context:timeRangeContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackLikelyToKeepUp"
                                context:playbackLikelyToKeepUpContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackBufferEmpty"
                                context:playbackBufferEmptyContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackBufferFull"
                                context:playbackBufferFullContext];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  AVAsset* asset = [_player.currentItem asset];
  [asset cancelLoading];
}

- (void)itemDidPlayToEndTime:(NSNotification*)notification {
  if (_isLooping) {
    AVPlayerItem* p = [notification object];
    [p seekToTime:kCMTimeZero completionHandler:nil];
  } else {
    if (_eventSink) {
      _eventSink(@{@"event" : @"completed", @"key" : _key});
    }
  }
}

static inline CGFloat radiansToDegrees(CGFloat radians) {
  // Input range [-pi, pi] or [-180, 180]
  CGFloat degrees = GLKMathRadiansToDegrees((float)radians);
  if (degrees < 0) {
    // Convert -90 to 270 and -180 to 180
    return degrees + 360;
  }
  // Output degrees in between [0, 360[
  return degrees;
};

- (AVMutableVideoComposition*)getVideoCompositionWithTransform:(CGAffineTransform)transform
                                                     withAsset:(AVAsset*)asset
                                                withVideoTrack:(AVAssetTrack*)videoTrack {
  AVMutableVideoCompositionInstruction* instruction =
      [AVMutableVideoCompositionInstruction videoCompositionInstruction];
  instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);
  AVMutableVideoCompositionLayerInstruction* layerInstruction =
      [AVMutableVideoCompositionLayerInstruction
          videoCompositionLayerInstructionWithAssetTrack:videoTrack];
  [layerInstruction setTransform:_preferredTransform atTime:kCMTimeZero];

  AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
  instruction.layerInstructions = @[ layerInstruction ];
  videoComposition.instructions = @[ instruction ];

  // If in portrait mode, switch the width and height of the video
  CGFloat width = videoTrack.naturalSize.width;
  CGFloat height = videoTrack.naturalSize.height;
  NSInteger rotationDegrees =
      (NSInteger)round(radiansToDegrees(atan2(_preferredTransform.b, _preferredTransform.a)));
  if (rotationDegrees == 90 || rotationDegrees == 270) {
    width = videoTrack.naturalSize.height;
    height = videoTrack.naturalSize.width;
  }
  videoComposition.renderSize = CGSizeMake(width, height);

  // TODO(@recastrodiaz): should we use videoTrack.nominalFrameRate ?
  // Currently set at a constant 30 FPS
  videoComposition.frameDuration = CMTimeMake(1, 30);

  return videoComposition;
}

- (void)addVideoOutput {
  if (_player.currentItem == nil) {
    return;
  }

  if (_videoOutput) {
    NSArray<AVPlayerItemOutput*>* outputs = [[_player currentItem] outputs];
    for (AVPlayerItemOutput* output in outputs) {
      if (output == _videoOutput) {
        return;
      }
    }
  }

  NSDictionary* pixBuffAttributes = @{
    (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
    (id)kCVPixelBufferIOSurfacePropertiesKey : @{}
  };
  _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
  [_player.currentItem addOutput:_videoOutput];
}

- (CGAffineTransform)fixTransform:(AVAssetTrack*)videoTrack {
  CGAffineTransform transform = videoTrack.preferredTransform;
  // TODO(@recastrodiaz): why do we need to do this? Why is the preferredTransform incorrect?
  // At least 2 user videos show a black screen when in portrait mode if we directly use the
  // videoTrack.preferredTransform Setting tx to the height of the video instead of 0, properly
  // displays the video https://github.com/flutter/flutter/issues/17606#issuecomment-413473181
  if (transform.tx == 0 && transform.ty == 0) {
    NSInteger rotationDegrees = (NSInteger)round(radiansToDegrees(atan2(transform.b, transform.a)));
    NSLog(@"TX and TY are 0. Rotation: %ld. Natural width,height: %f, %f", (long)rotationDegrees,
          videoTrack.naturalSize.width, videoTrack.naturalSize.height);
    if (rotationDegrees == 90) {
      NSLog(@"Setting transform tx");
      transform.tx = videoTrack.naturalSize.height;
      transform.ty = 0;
    } else if (rotationDegrees == 270) {
      NSLog(@"Setting transform ty");
      transform.tx = 0;
      transform.ty = videoTrack.naturalSize.width;
    }
  }
  return transform;
}

- (void)setDataSourceAsset:(NSString*)asset withKey:(NSString*)key {
  NSString* path = [[NSBundle mainBundle] pathForResource:asset ofType:nil];
  return [self setDataSourceURL:[NSURL fileURLWithPath:path] withKey:key];
}

- (void)setDataSourceURL:(NSURL*)url withKey:(NSString*)key {
  AVPlayerItem* item = [AVPlayerItem playerItemWithURL:url];
  return [self setDataSourcePlayerItem:item withKey:key];
}

- (void)setDataSourcePlayerItem:(AVPlayerItem*)item withKey:(NSString*)key {
  _key = key;
  [_player replaceCurrentItemWithPlayerItem:item];

  AVAsset* asset = [item asset];
  void (^assetCompletionHandler)(void) = ^{
    if ([asset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
      NSArray* tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
      if ([tracks count] > 0) {
        AVAssetTrack* videoTrack = tracks[0];
        void (^trackCompletionHandler)(void) = ^{
          if (self->_disposed) return;
          if ([videoTrack statusOfValueForKey:@"preferredTransform"
                                        error:nil] == AVKeyValueStatusLoaded) {
            // Rotate the video by using a videoComposition and the preferredTransform
            self->_preferredTransform = [self fixTransform:videoTrack];
            // Note:
            // https://developer.apple.com/documentation/avfoundation/avplayeritem/1388818-videocomposition
            // Video composition can only be used with file-based media and is not supported for
            // use with media served using HTTP Live Streaming.
            AVMutableVideoComposition* videoComposition =
                [self getVideoCompositionWithTransform:self->_preferredTransform
                                             withAsset:asset
                                        withVideoTrack:videoTrack];
            item.videoComposition = videoComposition;
          }
        };
        [videoTrack loadValuesAsynchronouslyForKeys:@[ @"preferredTransform" ]
                                  completionHandler:trackCompletionHandler];
      }
    }
  };

  [asset loadValuesAsynchronouslyForKeys:@[ @"tracks" ] completionHandler:assetCompletionHandler];
  [self addObservers:item];
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
        int64_t start = FLTCMTimeToMillis(range.start);
        [values addObject:@[ @(start), @(start + FLTCMTimeToMillis(range.duration)) ]];
      }
      _eventSink(@{@"event" : @"bufferingUpdate", @"values" : values, @"key" : _key});
    }
  } else if (context == statusContext) {
    AVPlayerItem* item = (AVPlayerItem*)object;
    switch (item.status) {
      case AVPlayerItemStatusFailed:
        if (_eventSink != nil) {
          _eventSink([FlutterError
              errorWithCode:@"VideoError"
                    message:[@"Failed to load video: "
                                stringByAppendingString:[item.error localizedDescription]]
                    details:nil]);
        }
        break;
      case AVPlayerItemStatusUnknown:
        break;
      case AVPlayerItemStatusReadyToPlay:
        [self onReadyToPlay];
        break;
    }
  } else if (context == playbackLikelyToKeepUpContext) {
    if ([[_player currentItem] isPlaybackLikelyToKeepUp]) {
      [self updatePlayingState];
      if (_eventSink != nil) {
        _eventSink(@{@"event" : @"bufferingEnd", @"key" : _key});
      }
    }
  } else if (context == playbackBufferEmptyContext) {
    if (_eventSink != nil) {
      _eventSink(@{@"event" : @"bufferingStart", @"key" : _key});
    }
  } else if (context == playbackBufferFullContext) {
    if (_eventSink != nil) {
      _eventSink(@{@"event" : @"bufferingEnd", @"key" : _key});
    }
  }
}

- (void)updatePlayingState {
  if (!_isInitialized || !_key) {
    _displayLink.paused = YES;
    return;
  }

  if (_isPlaying) {
    [_player play];
  } else {
    [_player pause];
  }
  _displayLink.paused = !_isPlaying;
}

- (void)onReadyToPlay {
  if (_eventSink && !_isInitialized && _key) {
    if (!_player.currentItem) {
      return;
    }
    if (_player.status != AVPlayerStatusReadyToPlay) {
      return;
    }

    CGSize size = [_player currentItem].presentationSize;
    CGFloat width = size.width;
    CGFloat height = size.height;

    // The player has not yet initialized.
    if (height == CGSizeZero.height && width == CGSizeZero.width) {
      return;
    }
    // The player may be initialized but still needs to determine the duration.
    if ([self duration] == 0) {
      return;
    }

    _isInitialized = true;
    [self addVideoOutput];
    [self updatePlayingState];
    _eventSink(@{
      @"event" : @"initialized",
      @"duration" : @([self duration]),
      @"width" : @(width),
      @"height" : @(height),
      @"key" : _key
    });
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
  return FLTCMTimeToMillis([_player currentTime]);
}

- (int64_t)duration {
  return FLTCMTimeToMillis([[_player currentItem] duration]);
}

- (void)seekTo:(int)location {
  [_player seekToTime:CMTimeMake(location, 1000)
      toleranceBefore:kCMTimeZero
       toleranceAfter:kCMTimeZero];
}

- (void)setIsLooping:(bool)isLooping {
  _isLooping = isLooping;
}

- (void)setVolume:(double)volume {
  _player.volume = (float)((volume < 0.0) ? 0.0 : ((volume > 1.0) ? 1.0 : volume));
}

// This workaround if you will change dataSource. Flutter engine caches CVPixelBufferRef and if you
// return NULL from method copyPixelBuffer Flutter will use cached CVPixelBufferRef. If you will
// change your datasource you can see frame from previeous video. Thats why we should return
// trasparent frame for this situation
- (CVPixelBufferRef)prevTransparentBuffer {
  if (_prevBuffer) {
    CVPixelBufferLockBaseAddress(_prevBuffer, 0);

    int bufferWidth = CVPixelBufferGetWidth(_prevBuffer);
    int bufferHeight = CVPixelBufferGetHeight(_prevBuffer);
    unsigned char* pixel = (unsigned char*)CVPixelBufferGetBaseAddress(_prevBuffer);

    for (int row = 0; row < bufferHeight; row++) {
      for (int column = 0; column < bufferWidth; column++) {
        pixel[0] = 0;
        pixel[1] = 0;
        pixel[2] = 0;
        pixel[3] = 0;
        pixel += 4;
      }
    }
    CVPixelBufferUnlockBaseAddress(_prevBuffer, 0);
    return _prevBuffer;
  }
  return _prevBuffer;
}

- (CVPixelBufferRef)copyPixelBuffer {
  if (!_videoOutput || !_isInitialized || !_isPlaying || !_key || ![_player currentItem] ||
      ![[_player currentItem] isPlaybackLikelyToKeepUp]) {
    return [self prevTransparentBuffer];
  }

  CMTime outputItemTime = [_videoOutput itemTimeForHostTime:CACurrentMediaTime()];
  if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
    _failedCount = 0;
    _prevBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
    return _prevBuffer;
  } else {
    // AVPlayerItemVideoOutput.hasNewPixelBufferForItemTime doesn't work correctly
    _failedCount++;
    if (_failedCount > 100) {
      _failedCount = 0;
      [self removeVideoOutput];
      [self addVideoOutput];
    }
    return NULL;
  }
}

- (void)onTextureUnregistered {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dispose];
  });
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  _eventSink = nil;
  return nil;
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  _eventSink = events;
  // TODO(@recastrodiaz): remove the line below when the race condition is resolved:
  // https://github.com/flutter/flutter/issues/21483
  // This line ensures the 'initialized' event is sent when the event
  // 'AVPlayerItemStatusReadyToPlay' fires before _eventSink is set (this function
  // onListenWithArguments is called)
  [self onReadyToPlay];
  return nil;
}

/// This method allows you to dispose without touching the event channel.  This
/// is useful for the case where the Engine is in the process of deconstruction
/// so the channel is going to die or is already dead.
- (void)disposeSansEventChannel {
  [self clear];
  [_displayLink invalidate];
  [[_player currentItem] removeObserver:self forKeyPath:@"status" context:statusContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"loadedTimeRanges"
                                context:timeRangeContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackLikelyToKeepUp"
                                context:playbackLikelyToKeepUpContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackBufferEmpty"
                                context:playbackBufferEmptyContext];
  [[_player currentItem] removeObserver:self
                             forKeyPath:@"playbackBufferFull"
                                context:playbackBufferFullContext];
  [_player replaceCurrentItemWithPlayerItem:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dispose {
  [self disposeSansEventChannel];
  [_eventChannel setStreamHandler:nil];
  _disposed = true;
}

@end

@interface FLTVideoPlayerPlugin ()
@property(readonly, weak, nonatomic) NSObject<FlutterTextureRegistry>* registry;
@property(readonly, weak, nonatomic) NSObject<FlutterBinaryMessenger>* messenger;
@property(readonly, strong, nonatomic) NSMutableDictionary* players;
@property(readonly, strong, nonatomic) NSObject<FlutterPluginRegistrar>* registrar;
@end

@implementation FLTVideoPlayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"flutter.io/videoPlayer"
                                  binaryMessenger:[registrar messenger]];
  FLTVideoPlayerPlugin* instance = [[FLTVideoPlayerPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar publish:instance];
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  NSAssert(self, @"super init cannot be nil");
  _registry = [registrar textures];
  _messenger = [registrar messenger];
  _registrar = registrar;
  _players = [NSMutableDictionary dictionaryWithCapacity:1];
  return self;
}

- (void)detachFromEngineForRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  for (NSNumber* textureId in _players.allKeys) {
    FLTVideoPlayer* player = _players[textureId];
    [player disposeSansEventChannel];
  }
  [_players removeAllObjects];
}

- (void)onPlayerSetup:(FLTVideoPlayer*)player
         frameUpdater:(FLTFrameUpdater*)frameUpdater
               result:(FlutterResult)result {
  int64_t textureId = [_registry registerTexture:player];
  frameUpdater.textureId = textureId;
  FlutterEventChannel* eventChannel = [FlutterEventChannel
      eventChannelWithName:[NSString stringWithFormat:@"flutter.io/videoPlayer/videoEvents%lld",
                                                      textureId]
           binaryMessenger:_messenger];
  [eventChannel setStreamHandler:player];
  player.eventChannel = eventChannel;
  _players[@(textureId)] = player;
  result(@{@"textureId" : @(textureId)});
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
    // Allow audio playback when the Ring/Silent switch is set to silent
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];

    for (NSNumber* textureId in _players) {
      [_registry unregisterTexture:[textureId unsignedIntegerValue]];
      [_players[textureId] dispose];
    }
    [_players removeAllObjects];
    result(nil);
  } else if ([@"create" isEqualToString:call.method]) {
    FLTFrameUpdater* frameUpdater = [[FLTFrameUpdater alloc] initWithRegistry:_registry];
    FLTVideoPlayer* player = [[FLTVideoPlayer alloc] initWithFrameUpdater:frameUpdater];
    [self onPlayerSetup:player frameUpdater:frameUpdater result:result];
  } else {
    NSDictionary* argsMap = call.arguments;
    int64_t textureId = ((NSNumber*)argsMap[@"textureId"]).unsignedIntegerValue;
    FLTVideoPlayer* player = _players[@(textureId)];
    if ([@"setDataSource" isEqualToString:call.method]) {
      [player clear];
      // This call will clear cached frame because we will return transparent frame
      [_registry textureFrameAvailable:textureId];
      NSDictionary* dataSource = argsMap[@"dataSource"];
      NSString* assetArg = dataSource[@"asset"];
      NSString* uriArg = dataSource[@"uri"];
      NSString* key = dataSource[@"key"];
      if (assetArg) {
        NSString* assetPath;
        NSString* package = dataSource[@"package"];
        if (![package isEqual:[NSNull null]]) {
          assetPath = [_registrar lookupKeyForAsset:assetArg fromPackage:package];
        } else {
          assetPath = [_registrar lookupKeyForAsset:assetArg];
        }
        [player setDataSourceAsset:assetPath withKey:key];
      } else if (uriArg) {
        [player setDataSourceURL:[NSURL URLWithString:uriArg] withKey:key];
      } else {
        result(FlutterMethodNotImplemented);
      }
      result(nil);
    } else if ([@"dispose" isEqualToString:call.method]) {
      [_registry unregisterTexture:textureId];
      [_players removeObjectForKey:@(textureId)];
      // If the Flutter contains https://github.com/flutter/engine/pull/12695,
      // the `player` is disposed via `onTextureUnregistered` at the right time.
      // Without https://github.com/flutter/engine/pull/12695, there is no guarantee that the
      // texture has completed the un-reregistration. It may leads a crash if we dispose the
      // `player` before the texture is unregistered. We add a dispatch_after hack to make sure the
      // texture is unregistered before we dispose the `player`.
      //
      // TODO(cyanglaz): Remove this dispatch block when
      // https://github.com/flutter/flutter/commit/8159a9906095efc9af8b223f5e232cb63542ad0b is in
      // stable And update the min flutter version of the plugin to the stable version.
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                     dispatch_get_main_queue(), ^{
                       if (!player.disposed) {
                         [player dispose];
                       }
                     });
      result(nil);
    } else if ([@"setLooping" isEqualToString:call.method]) {
      [player setIsLooping:[argsMap[@"looping"] boolValue]];
      result(nil);
    } else if ([@"setVolume" isEqualToString:call.method]) {
      [player setVolume:[argsMap[@"volume"] doubleValue]];
      result(nil);
    } else if ([@"play" isEqualToString:call.method]) {
      [player play];
      result(nil);
    } else if ([@"position" isEqualToString:call.method]) {
      result(@([player position]));
    } else if ([@"seekTo" isEqualToString:call.method]) {
      [player seekTo:[argsMap[@"location"] intValue]];
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
