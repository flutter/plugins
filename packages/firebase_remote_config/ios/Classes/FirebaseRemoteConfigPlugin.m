#import "FirebaseRemoteConfigPlugin.h"

#import <Firebase/Firebase.h>

@implementation FirebaseRemoteConfigPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"firebase_remote_config"
            binaryMessenger:[registrar messenger]];
  FirebaseRemoteConfigPlugin* instance = [[FirebaseRemoteConfigPlugin alloc] init];
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
  if ([@"RemoteConfig#fetch" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    bool debugMode = (bool) call.arguments[@"debugMode"];
    long expiration = (long) call.arguments[@"expiration"];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:debugMode];
    [remoteConfig setConfigSettings:remoteConfigSettings];

    [remoteConfig fetchWithExpirationDuration:expiration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        if (status == FIRRemoteConfigFetchStatusSuccess) {
          [remoteConfig activateFetched];
          NSSet *keySet = [remoteConfig keysWithPrefix:@""];
          for (NSString *key in keySet) {
            resultDict[key] = [FlutterStandardTypedData typedDataWithBytes:[[remoteConfig configValueForKey:key] dataValue]];
          }
        }
        result(resultDict);
    }];
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    NSDictionary *defaults = call.arguments[@"parameters"];
    [remoteConfig setDefaults:defaults];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
