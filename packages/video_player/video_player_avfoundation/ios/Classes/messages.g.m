// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v2.0.4), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import "messages.g.h"
#import <Flutter/Flutter.h>

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSDictionary<NSString *, id> *wrapResult(id result, FlutterError *error) {
  NSDictionary *errorDict = (NSDictionary *)[NSNull null];
  if (error) {
    errorDict = @{
        @"code": (error.code ? error.code : [NSNull null]),
        @"message": (error.message ? error.message : [NSNull null]),
        @"details": (error.details ? error.details : [NSNull null]),
        };
  }
  return @{
      @"result": (result ? result : [NSNull null]),
      @"error": errorDict,
      };
}
static id GetNullableObject(NSDictionary* dict, id key) {
  id result = dict[key];
  return (result == [NSNull null]) ? nil : result;
}
static id GetNullableObjectAtIndex(NSArray* array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}


@interface FLTTextureMessage ()
+ (FLTTextureMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTLoopingMessage ()
+ (FLTLoopingMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTVolumeMessage ()
+ (FLTVolumeMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTPlaybackSpeedMessage ()
+ (FLTPlaybackSpeedMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTMaxVideoResolutionMessage ()
+ (FLTMaxVideoResolutionMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTPositionMessage ()
+ (FLTPositionMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTCreateMessage ()
+ (FLTCreateMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end
@interface FLTMixWithOthersMessage ()
+ (FLTMixWithOthersMessage *)fromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation FLTTextureMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId {
  FLTTextureMessage* pigeonResult = [[FLTTextureMessage alloc] init];
  pigeonResult.textureId = textureId;
  return pigeonResult;
}
+ (FLTTextureMessage *)fromMap:(NSDictionary *)dict {
  FLTTextureMessage *pigeonResult = [[FLTTextureMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", nil];
}
@end

@implementation FLTLoopingMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId
    isLooping:(NSNumber *)isLooping {
  FLTLoopingMessage* pigeonResult = [[FLTLoopingMessage alloc] init];
  pigeonResult.textureId = textureId;
  pigeonResult.isLooping = isLooping;
  return pigeonResult;
}
+ (FLTLoopingMessage *)fromMap:(NSDictionary *)dict {
  FLTLoopingMessage *pigeonResult = [[FLTLoopingMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  pigeonResult.isLooping = GetNullableObject(dict, @"isLooping");
  NSAssert(pigeonResult.isLooping != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.isLooping ? self.isLooping : [NSNull null]), @"isLooping", nil];
}
@end

@implementation FLTVolumeMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId
    volume:(NSNumber *)volume {
  FLTVolumeMessage* pigeonResult = [[FLTVolumeMessage alloc] init];
  pigeonResult.textureId = textureId;
  pigeonResult.volume = volume;
  return pigeonResult;
}
+ (FLTVolumeMessage *)fromMap:(NSDictionary *)dict {
  FLTVolumeMessage *pigeonResult = [[FLTVolumeMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  pigeonResult.volume = GetNullableObject(dict, @"volume");
  NSAssert(pigeonResult.volume != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.volume ? self.volume : [NSNull null]), @"volume", nil];
}
@end

@implementation FLTPlaybackSpeedMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId
    speed:(NSNumber *)speed {
  FLTPlaybackSpeedMessage* pigeonResult = [[FLTPlaybackSpeedMessage alloc] init];
  pigeonResult.textureId = textureId;
  pigeonResult.speed = speed;
  return pigeonResult;
}
+ (FLTPlaybackSpeedMessage *)fromMap:(NSDictionary *)dict {
  FLTPlaybackSpeedMessage *pigeonResult = [[FLTPlaybackSpeedMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  pigeonResult.speed = GetNullableObject(dict, @"speed");
  NSAssert(pigeonResult.speed != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.speed ? self.speed : [NSNull null]), @"speed", nil];
}
@end

@implementation FLTMaxVideoResolutionMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId
    width:(NSNumber *)width
    height:(NSNumber *)height {
  FLTMaxVideoResolutionMessage* pigeonResult = [[FLTMaxVideoResolutionMessage alloc] init];
  pigeonResult.textureId = textureId;
  pigeonResult.width = width;
  pigeonResult.height = height;
  return pigeonResult;
}
+ (FLTMaxVideoResolutionMessage *)fromMap:(NSDictionary *)dict {
  FLTMaxVideoResolutionMessage *pigeonResult = [[FLTMaxVideoResolutionMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  pigeonResult.width = GetNullableObject(dict, @"width");
  NSAssert(pigeonResult.width != nil, @"");
  pigeonResult.height = GetNullableObject(dict, @"height");
  NSAssert(pigeonResult.height != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.width ? self.width : [NSNull null]), @"width", (self.height ? self.height : [NSNull null]), @"height", nil];
}
@end

@implementation FLTPositionMessage
+ (instancetype)makeWithTextureId:(NSNumber *)textureId
    position:(NSNumber *)position {
  FLTPositionMessage* pigeonResult = [[FLTPositionMessage alloc] init];
  pigeonResult.textureId = textureId;
  pigeonResult.position = position;
  return pigeonResult;
}
+ (FLTPositionMessage *)fromMap:(NSDictionary *)dict {
  FLTPositionMessage *pigeonResult = [[FLTPositionMessage alloc] init];
  pigeonResult.textureId = GetNullableObject(dict, @"textureId");
  NSAssert(pigeonResult.textureId != nil, @"");
  pigeonResult.position = GetNullableObject(dict, @"position");
  NSAssert(pigeonResult.position != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.textureId ? self.textureId : [NSNull null]), @"textureId", (self.position ? self.position : [NSNull null]), @"position", nil];
}
@end

@implementation FLTCreateMessage
+ (instancetype)makeWithAsset:(nullable NSString *)asset
    uri:(nullable NSString *)uri
    packageName:(nullable NSString *)packageName
    formatHint:(nullable NSString *)formatHint
    httpHeaders:(NSDictionary<NSString *, NSString *> *)httpHeaders {
  FLTCreateMessage* pigeonResult = [[FLTCreateMessage alloc] init];
  pigeonResult.asset = asset;
  pigeonResult.uri = uri;
  pigeonResult.packageName = packageName;
  pigeonResult.formatHint = formatHint;
  pigeonResult.httpHeaders = httpHeaders;
  return pigeonResult;
}
+ (FLTCreateMessage *)fromMap:(NSDictionary *)dict {
  FLTCreateMessage *pigeonResult = [[FLTCreateMessage alloc] init];
  pigeonResult.asset = GetNullableObject(dict, @"asset");
  pigeonResult.uri = GetNullableObject(dict, @"uri");
  pigeonResult.packageName = GetNullableObject(dict, @"packageName");
  pigeonResult.formatHint = GetNullableObject(dict, @"formatHint");
  pigeonResult.httpHeaders = GetNullableObject(dict, @"httpHeaders");
  NSAssert(pigeonResult.httpHeaders != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.asset ? self.asset : [NSNull null]), @"asset", (self.uri ? self.uri : [NSNull null]), @"uri", (self.packageName ? self.packageName : [NSNull null]), @"packageName", (self.formatHint ? self.formatHint : [NSNull null]), @"formatHint", (self.httpHeaders ? self.httpHeaders : [NSNull null]), @"httpHeaders", nil];
}
@end

@implementation FLTMixWithOthersMessage
+ (instancetype)makeWithMixWithOthers:(NSNumber *)mixWithOthers {
  FLTMixWithOthersMessage* pigeonResult = [[FLTMixWithOthersMessage alloc] init];
  pigeonResult.mixWithOthers = mixWithOthers;
  return pigeonResult;
}
+ (FLTMixWithOthersMessage *)fromMap:(NSDictionary *)dict {
  FLTMixWithOthersMessage *pigeonResult = [[FLTMixWithOthersMessage alloc] init];
  pigeonResult.mixWithOthers = GetNullableObject(dict, @"mixWithOthers");
  NSAssert(pigeonResult.mixWithOthers != nil, @"");
  return pigeonResult;
}
- (NSDictionary *)toMap {
  return [NSDictionary dictionaryWithObjectsAndKeys:(self.mixWithOthers ? self.mixWithOthers : [NSNull null]), @"mixWithOthers", nil];
}
@end

@interface FLTAVFoundationVideoPlayerApiCodecReader : FlutterStandardReader
@end
@implementation FLTAVFoundationVideoPlayerApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FLTCreateMessage fromMap:[self readValue]];
    
    case 129:     
      return [FLTLoopingMessage fromMap:[self readValue]];
    
    case 130:     
      return [FLTMaxVideoResolutionMessage fromMap:[self readValue]];
    
    case 131:     
      return [FLTMixWithOthersMessage fromMap:[self readValue]];
    
    case 132:     
      return [FLTPlaybackSpeedMessage fromMap:[self readValue]];
    
    case 133:     
      return [FLTPositionMessage fromMap:[self readValue]];
    
    case 134:     
      return [FLTTextureMessage fromMap:[self readValue]];
    
    case 135:     
      return [FLTVolumeMessage fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FLTAVFoundationVideoPlayerApiCodecWriter : FlutterStandardWriter
@end
@implementation FLTAVFoundationVideoPlayerApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FLTCreateMessage class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTLoopingMessage class]]) {
    [self writeByte:129];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTMaxVideoResolutionMessage class]]) {
    [self writeByte:130];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTMixWithOthersMessage class]]) {
    [self writeByte:131];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTPlaybackSpeedMessage class]]) {
    [self writeByte:132];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTPositionMessage class]]) {
    [self writeByte:133];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTTextureMessage class]]) {
    [self writeByte:134];
    [self writeValue:[value toMap]];
  } else 
  if ([value isKindOfClass:[FLTVolumeMessage class]]) {
    [self writeByte:135];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FLTAVFoundationVideoPlayerApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FLTAVFoundationVideoPlayerApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FLTAVFoundationVideoPlayerApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FLTAVFoundationVideoPlayerApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FLTAVFoundationVideoPlayerApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FLTAVFoundationVideoPlayerApiCodecReaderWriter *readerWriter = [[FLTAVFoundationVideoPlayerApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FLTAVFoundationVideoPlayerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FLTAVFoundationVideoPlayerApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.initialize"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(initialize:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(initialize:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        FlutterError *error;
        [api initialize:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.create"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(create:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(create:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTCreateMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        FLTTextureMessage *output = [api create:arg_msg error:&error];
        callback(wrapResult(output, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.dispose"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(dispose:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(dispose:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTTextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api dispose:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.setLooping"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setLooping:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(setLooping:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTLoopingMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setLooping:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.setVolume"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setVolume:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(setVolume:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTVolumeMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setVolume:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.setPlaybackSpeed"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setPlaybackSpeed:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(setPlaybackSpeed:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTPlaybackSpeedMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setPlaybackSpeed:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.setMaxVideoResolution"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setMaxVideoResolution:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(setMaxVideoResolution:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTMaxVideoResolutionMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setMaxVideoResolution:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.play"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(play:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(play:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTTextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api play:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.position"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(position:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(position:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTTextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        FLTPositionMessage *output = [api position:arg_msg error:&error];
        callback(wrapResult(output, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.seekTo"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(seekTo:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(seekTo:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTPositionMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api seekTo:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.pause"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(pause:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(pause:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTTextureMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api pause:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.AVFoundationVideoPlayerApi.setMixWithOthers"
        binaryMessenger:binaryMessenger
        codec:FLTAVFoundationVideoPlayerApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(setMixWithOthers:error:)], @"FLTAVFoundationVideoPlayerApi api (%@) doesn't respond to @selector(setMixWithOthers:error:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FLTMixWithOthersMessage *arg_msg = GetNullableObjectAtIndex(args, 0);
        FlutterError *error;
        [api setMixWithOthers:arg_msg error:&error];
        callback(wrapResult(nil, error));
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
