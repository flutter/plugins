#import "GoogleMapsPlugin.h"

@implementation FLTGoogleMapsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/google_maps"
                                  binaryMessenger:[registrar messenger]];
  FLTGoogleMapsPlugin* instance = [[FLTGoogleMapsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end
