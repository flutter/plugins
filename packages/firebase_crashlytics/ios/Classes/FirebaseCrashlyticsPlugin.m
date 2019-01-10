#import "FirebaseCrashlyticsPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseCrashlyticsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseCrashlyticsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_crashlytics"
            binaryMessenger:[registrar messenger]];
  FirebaseCrashlyticsPlugin* instance = [[FirebaseCrashlyticsPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"Crashlytics#onError" isEqualToString:call.method]) {
    NSError *error = [NSError errorWithDomain:@"FlutterDomain"
                        code:-1
                    userInfo: @{
                            @"exception": call.arguments[@"exception"],
                            @"stackTrace": call.arguments[@"stackTrace"]
                    }];
    [[Crashlytics sharedInstance] recordError:error];
    result(@"success");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
