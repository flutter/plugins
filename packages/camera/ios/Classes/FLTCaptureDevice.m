#import "CameraPlugin+Internal.h"

@interface FLTCaptureDevice ()
@property AVCaptureDevice *device;
@end

@implementation FLTCaptureDevice
@synthesize handle;

+ (NSArray<NSDictionary *> *_Nonnull)getDevices:(FlutterMethodCall *_Nonnull)call {
  NSString *mediaTypeStr = call.arguments[@"mediaType"];

  AVMediaType mediaType = nil;
  if ([@"MediaType.video" isEqualToString:mediaTypeStr]) {
    mediaType = AVMediaTypeVideo;
  }

  NSArray<AVCaptureDevice *> *devices;
  if (mediaType) {
    devices = [AVCaptureDevice devicesWithMediaType:mediaType];
  } else {
    devices = [AVCaptureDevice devices];
  }

  NSMutableArray<NSDictionary<NSString *, NSObject *> *> *deviceData =
      [[NSMutableArray alloc] initWithCapacity:devices.count];

  for (AVCaptureDevice *device in devices) {
    [deviceData addObject:[FLTCaptureDevice serialize:device]];
  }

  return deviceData;
}

+ (AVCaptureDevice *_Nonnull)deserialize:(NSDictionary *_Nonnull)data {
  NSString *uniqueId = data[@"uniqueId"];
  return [AVCaptureDevice deviceWithUniqueID:uniqueId];
}

+ (NSDictionary *_Nonnull)serialize:(AVCaptureDevice *_Nonnull)device {
  NSString *retPositionStr;
  switch ([device position]) {
    case AVCaptureDevicePositionBack:
      retPositionStr = @"CaptureDevicePosition.back";
      break;
    case AVCaptureDevicePositionFront:
      retPositionStr = @"CaptureDevicePosition.front";
      break;
    case AVCaptureDevicePositionUnspecified:
      retPositionStr = @"CaptureDevicePosition.unspecified";
      break;
  }

  return @{
    @"uniqueId" : [device uniqueID],
    @"position" : retPositionStr,
  };
}

- (instancetype _Nonnull)initWithCaptureDevice:(AVCaptureDevice *_Nonnull)device
                                        handle:(NSNumber *)handle {
  self = [self init];
  if (self) {
    self.handle = handle;
  }

  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result {
  result(FlutterMethodNotImplemented);
}
@end
