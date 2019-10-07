#import "InstrumentationAdapterPlugin.h"

@implementation InstrumentationAdapterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dev.flutter/InstrumentationAdapterFlutterBinding"
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
