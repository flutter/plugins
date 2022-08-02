// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v3.2.5), do not edit directly.
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
        @"code": (error.code ?: [NSNull null]),
        @"message": (error.message ?: [NSNull null]),
        @"details": (error.details ?: [NSNull null]),
        };
  }
  return @{
      @"result": (result ?: [NSNull null]),
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


@interface FFSFileSelectorConfig ()
+ (FFSFileSelectorConfig *)fromMap:(NSDictionary *)dict;
+ (nullable FFSFileSelectorConfig *)nullableFromMap:(NSDictionary *)dict;
- (NSDictionary *)toMap;
@end

@implementation FFSFileSelectorConfig
+ (instancetype)makeWithUtis:(NSArray<NSString *> *)utis
    allowMultiSelection:(NSNumber *)allowMultiSelection {
  FFSFileSelectorConfig* pigeonResult = [[FFSFileSelectorConfig alloc] init];
  pigeonResult.utis = utis;
  pigeonResult.allowMultiSelection = allowMultiSelection;
  return pigeonResult;
}
+ (FFSFileSelectorConfig *)fromMap:(NSDictionary *)dict {
  FFSFileSelectorConfig *pigeonResult = [[FFSFileSelectorConfig alloc] init];
  pigeonResult.utis = GetNullableObject(dict, @"utis");
  NSAssert(pigeonResult.utis != nil, @"");
  pigeonResult.allowMultiSelection = GetNullableObject(dict, @"allowMultiSelection");
  NSAssert(pigeonResult.allowMultiSelection != nil, @"");
  return pigeonResult;
}
+ (nullable FFSFileSelectorConfig *)nullableFromMap:(NSDictionary *)dict { return (dict) ? [FFSFileSelectorConfig fromMap:dict] : nil; }
- (NSDictionary *)toMap {
  return @{
    @"utis" : (self.utis ?: [NSNull null]),
    @"allowMultiSelection" : (self.allowMultiSelection ?: [NSNull null]),
  };
}
@end

@interface FFSFileSelectorApiCodecReader : FlutterStandardReader
@end
@implementation FFSFileSelectorApiCodecReader
- (nullable id)readValueOfType:(UInt8)type 
{
  switch (type) {
    case 128:     
      return [FFSFileSelectorConfig fromMap:[self readValue]];
    
    default:    
      return [super readValueOfType:type];
    
  }
}
@end

@interface FFSFileSelectorApiCodecWriter : FlutterStandardWriter
@end
@implementation FFSFileSelectorApiCodecWriter
- (void)writeValue:(id)value 
{
  if ([value isKindOfClass:[FFSFileSelectorConfig class]]) {
    [self writeByte:128];
    [self writeValue:[value toMap]];
  } else 
{
    [super writeValue:value];
  }
}
@end

@interface FFSFileSelectorApiCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation FFSFileSelectorApiCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[FFSFileSelectorApiCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[FFSFileSelectorApiCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *FFSFileSelectorApiGetCodec() {
  static dispatch_once_t sPred = 0;
  static FlutterStandardMessageCodec *sSharedObject = nil;
  dispatch_once(&sPred, ^{
    FFSFileSelectorApiCodecReaderWriter *readerWriter = [[FFSFileSelectorApiCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}


void FFSFileSelectorApiSetup(id<FlutterBinaryMessenger> binaryMessenger, NSObject<FFSFileSelectorApi> *api) {
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:@"dev.flutter.pigeon.FileSelectorApi.openFile"
        binaryMessenger:binaryMessenger
        codec:FFSFileSelectorApiGetCodec()        ];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(openFileSelectorWithConfig:completion:)], @"FFSFileSelectorApi api (%@) doesn't respond to @selector(openFileSelectorWithConfig:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray *args = message;
        FFSFileSelectorConfig *arg_config = GetNullableObjectAtIndex(args, 0);
        [api openFileSelectorWithConfig:arg_config completion:^(NSArray<NSString *> *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    }
    else {
      [channel setMessageHandler:nil];
    }
  }
}
