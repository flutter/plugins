#import "FirebaseInappmessagingPlugin.h"

#import <Firebase/Firebase.h>

@implementation FirebaseInappmessagingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_inappmessaging"
            binaryMessenger:[registrar messenger]];
  FirebaseInappmessagingPlugin* instance = [[FirebaseInappmessagingPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
            NSLog(@"Configuring the default Firebase app...");
            [FIRApp configure];
            NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
        }
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"triggerEvent" isEqualToString:call.method]) {
      NSString *eventName = call.arguments[@"eventName"];
      FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
      [fiam triggerEvent:eventName];
      result(nil);
  } else if ([@"setMessagesSuppressed" isEqualToString:call.method]) {
      NSNumber *suppress = (NSNumber *) call.arguments[@"suppress"];
      FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
      fiam.messageDisplaySuppressed = [suppress boolValue];
      result(nil);
  } else if ([@"dataCollectionEnabled" isEqualToString:call.method]) {
      NSNumber *dataCollectionEnabled = (NSNumber *) call.arguments[@"dataCollectionEnabled"];
      FIRInAppMessaging *fiam = [FIRInAppMessaging inAppMessaging];
      fiam.automaticDataCollectionEnabled = [dataCollectionEnabled boolValue];
      result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
