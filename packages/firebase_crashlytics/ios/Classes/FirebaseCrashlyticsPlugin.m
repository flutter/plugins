#import "FirebaseCrashlyticsPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseCrashlyticsPlugin ()
@property(nonatomic, retain) FlutterMethodChannel* channel;
@end

@implementation FirebaseCrashlyticsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_crashlytics"
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
    NSError* error = [NSError errorWithDomain:call.arguments[@"exception"]
                                         code:(int)call.arguments[@"code"]
                                     userInfo:@{
                                       @"exception" : call.arguments[@"exception"],
                                       @"stackTrace" : call.arguments[@"stackTrace"]
                                     }];
    [[Crashlytics sharedInstance] recordError:error];
    result(@"Error reported to Crashlytics.");
  } else if ([@"Crashlytics#setInt" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setIntValue:(int)call.arguments[@"value"]
                                       forKey:call.arguments[@"key"]];
    result(nil);
  } else if ([@"Crashlytics#setDouble" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setFloatValue:[call.arguments[@"value"] floatValue]
                                         forKey:call.arguments[@"key"]];
    result(nil);
  } else if ([@"Crashlytics#setString" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setObjectValue:call.arguments[@"value"]
                                          forKey:call.arguments[@"key"]];
    result(nil);
  } else if ([@"Crashlytics#setBool" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setBoolValue:[call.arguments[@"value"] boolValue]
                                        forKey:call.arguments[@"key"]];
    result(nil);
  } else if ([@"Crashlytics#log" isEqualToString:call.method]) {
    CLS_LOG(@"%@", call.arguments[@"msg"]);
    result(nil);
  } else if ([@"Crashlytics#setUserEmail" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setUserEmail:call.arguments[@"email"]];
    result(nil);
  } else if ([@"Crashlytics#setUserName" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setUserName:call.arguments[@"name"]];
    result(nil);
  } else if ([@"Crashlytics#setUserIdentifier" isEqualToString:call.method]) {
    [[Crashlytics sharedInstance] setUserEmail:call.arguments[@"identifier"]];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
