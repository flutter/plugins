#import "PackageInfoPlugin.h"

@implementation PackageInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/package_info"
                                  binaryMessenger:[registrar messenger]];
  PackageInfoPlugin* instance = [[PackageInfoPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"getVersion"]) {
    result([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
  } else if ([call.method isEqualToString:@"getBuildNumber"]) {
    result([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
