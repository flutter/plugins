#import "CallbackPlugin.h"

@implementation CallbackPlugin {
  NSDictionary* _callbacks;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"callback"
            binaryMessenger:[registrar messenger]];
  CallbackPlugin* instance = [[CallbackPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  [registrar publish:instance];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _callbacks = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)registerCallback:(void (^)())callback withId:(NSString*)id {
  [_callbacks setValue:[callback copy] forKey:id];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"call" isEqualToString:call.method]) {
    NSString* callbackId = call.arguments[@"callbackId"];
    void (^ callback)() = _callbacks[callbackId];
    if (!callback) {
      result([FlutterError errorWithCode:@"UNKNOWN_CALLBACK"
                                 message:@"Callback is not registered."
                                 details:nil]);
      return;
    }
    callback();
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
