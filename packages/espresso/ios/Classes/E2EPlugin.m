#import "espressoPlugin.h"

@implementation espressoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.dev/espresso"
                                  binaryMessenger:[registrar messenger]];
  espressoPlugin* instance = [[espressoPlugin alloc] init];
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
