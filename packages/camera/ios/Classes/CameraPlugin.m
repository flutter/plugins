#import "CameraPlugin+Internal.h"

@interface CameraPlugin ()
@property id<FlutterPluginRegistrar> registrar;
@end

@implementation CameraPlugin
static NSMutableDictionary<NSNumber *, id<MethodCallHandler>> *methodHandlers;
static FlutterMethodChannel *channel;

- (instancetype _Nonnull)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar {
  self = [self init];
  if (self) {
    _registrar = registrar;
  }

  return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  methodHandlers = [NSMutableDictionary new];
  channel = [FlutterMethodChannel methodChannelWithName:@"dev.plugins/super_camera"
                                        binaryMessenger:[registrar messenger]];

  CameraPlugin *instance = [[CameraPlugin alloc] initWithRegistrar:registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

+ (void)addMethodHandler:(NSNumber *)handle methodHandler:(id<MethodCallHandler>)handler {
  if (methodHandlers[handle]) {
    NSString *reason =
        [[NSString alloc] initWithFormat:@"Object for handle already exists: %d", handle.intValue];
    @throw [[NSException alloc] initWithName:NSInvalidArgumentException reason:reason userInfo:nil];
  }

  methodHandlers[handle] = handler;
}

+ (void)removeMethodHandler:(NSNumber *)handle {
  [methodHandlers removeObjectForKey:handle];
}

+ (id<MethodCallHandler>)getHandler:(NSNumber *)handle {
  if (!handle) return nil;
  return methodHandlers[handle];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"CaptureDiscoverySession#devices" isEqualToString:call.method]) {
    result([FLTCaptureDiscoverySession devices:call]);
  } else if ([@"CaptureSession#startRunning" isEqualToString:call.method]) {
    [FLTCaptureSession startRunning:call result:result];
  } else if ([@"CaptureSession#stopRunning" isEqualToString:call.method]) {
    [FLTCaptureSession stopRunning:call result:result];
  } else if ([@"NativeTexture#allocate" isEqualToString:call.method]) {
    [self allocateTexture:call result:result];
  } else if ([@"CaptureDevice#devices" isEqualToString:call.method]) {
    result([FLTCaptureDevice getDevices:call]);
  } else {
    [self dispatchToHandler:call result:result];
  }
}

- (void)allocateTexture:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"textureHandle"];
  NativeTexture *texture = [[NativeTexture alloc] initWithTextureRegistry:_registrar.textures
                                                                   handle:handle];

  [CameraPlugin addMethodHandler:handle methodHandler:texture];
  result(@(texture.textureId));
}

- (void)dispatchToHandler:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSNumber *handle = call.arguments[@"handle"];
  id<MethodCallHandler> handler = [CameraPlugin getHandler:handle];

  if (handler) {
    [handler handleMethodCall:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
