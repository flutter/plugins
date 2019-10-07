#import "E2EPlugin.h"

@implementation E2EPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.dev/e2e"
                                  binaryMessenger:[registrar messenger]];
  InstrumentationAdapterPlugin* instance = [[InstrumentationAdapterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"allTestsFinished" isEqualToString:call.method]) {
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
