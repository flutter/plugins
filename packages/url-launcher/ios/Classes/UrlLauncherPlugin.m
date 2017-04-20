#import "UrlLauncherPlugin.h"

@implementation UrlLauncherPlugin {
}

- (instancetype)initWithController:(FlutterViewController *)controller {
  self = [super init];
  if (self) {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"plugins.flutter.io/URLLauncher"
                                     binaryMessenger:controller];
    [channel setMethodCallHandler:^(FlutterMethodCall *call,
                                    FlutterResult result) {
      if ([@"UrlLauncher.launch" isEqualToString:call.method]) {
        [self launchURL:call.arguments];
        result(nil);
      }
    }];
  }
  return self;
}

- (NSDictionary*)launchURL:(NSString*)urlString {
  NSURL* url = [NSURL URLWithString:urlString];
  UIApplication* application = [UIApplication sharedApplication];
  bool success = [application canOpenURL:url] && [application openURL:url];
  return @{@"success": @(success) };
}

@end
