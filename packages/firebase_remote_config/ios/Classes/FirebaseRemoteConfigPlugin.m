#import "FirebaseRemoteConfigPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseRemoteConfigPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_remote_config"
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
  if ([@"RemoteConfig#instance" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *firRemoteConfigSettings = [remoteConfig configSettings];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];

    resultDict[@"LAST_FETCH_TIME"] = [[NSNumber alloc] initWithLong: (long) [[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000];
    resultDict[@"LAST_FETCH_STATUS"] = [[NSNumber alloc] initWithInt:[self mapLastFetchStatus:(FIRRemoteConfigFetchStatus) [remoteConfig lastFetchStatus]]];
    resultDict[@"IN_DEBUG_MODE"] = [[NSNumber alloc] initWithBool:[firRemoteConfigSettings isDeveloperModeEnabled]];

    result(resultDict);
  } else if ([@"RemoteConfig#setConfigSettings" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    bool debugMode = (bool) call.arguments[@"debugMode"];
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:debugMode];
    [remoteConfig setConfigSettings:remoteConfigSettings];
    result(nil);
  } else if ([@"RemoteConfig#fetch" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    long expiration = (long) call.arguments[@"expiration"];

    [remoteConfig fetchWithExpirationDuration:expiration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
        resultDict[@"LAST_FETCH_TIME"] = [[NSNumber alloc] initWithLong: (long) [[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000];
        resultDict[@"LAST_FETCH_STATUS"] = [[NSNumber alloc] initWithInt:[self mapLastFetchStatus:(FIRRemoteConfigFetchStatus) [remoteConfig lastFetchStatus]]];

        if (status != FIRRemoteConfigFetchStatusSuccess) {
          [self.channel invokeMethod:@"UpdateFetch" arguments:resultDict result:^(id _Nullable updateFetchResult) {
              if ([updateFetchResult isKindOfClass:[FlutterError class]]) {
                // TODO: handle appropriately
                NSLog(@"Error when updating fetch");
              } else if ([updateFetchResult isEqual:FlutterMethodNotImplemented]) {
                // TODO: handle appropriately
                NSLog(@"Update fetch not implemented");
              } else {
                if (status == FIRRemoteConfigFetchStatusThrottled) {
                  NSMutableDictionary *details = [[NSMutableDictionary alloc] init];
                  int mills = [[error valueForKey:FIRRemoteConfigThrottledEndTimeInSecondsKey] intValue] * 1000;
                  details[@"FETCH_THROTTLED_END"] = [[NSNumber alloc] initWithInt: mills];

                  FlutterError *flutterError = [FlutterError errorWithCode:@"FETCH_FAILED_THROTTLED"
                                                                   message:nil
                                                                   details: details];
                  result(flutterError);
                } else {
                  FlutterError *flutterError = [FlutterError errorWithCode:@"FETCH_FAILED"
                                                                   message:nil
                                                                   details: nil];
                  result(flutterError);
                }
              }
          }];
        } else {
          result(resultDict);
        }
    }];
  } else if ([@"RemoteConfig#activate" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    [remoteConfig activateFetched];

    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];

    NSSet *keySet = [remoteConfig keysWithPrefix:@""];
    for (NSString *key in keySet) {
      NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
      valueDict[@"value"] = [FlutterStandardTypedData typedDataWithBytes:[[remoteConfig configValueForKey:key] dataValue]];
      valueDict[@"source"] = [[NSNumber alloc] initWithInt: [self mapValueSource:[[remoteConfig configValueForKey:key] source]]];
      parameterDict[key] = valueDict;
    }
    NSArray *defaultKeys = [[NSUserDefaults standardUserDefaults] arrayForKey:@"default_keys"];
    for (NSString *key in defaultKeys) {
      if ([parameterDict valueForKey:key] == nil) {
        NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
        valueDict[@"value"] = [FlutterStandardTypedData typedDataWithBytes:[[remoteConfig configValueForKey:key] dataValue]];
        valueDict[@"source"] = [[NSNumber alloc] initWithInt: [self mapValueSource:[[remoteConfig configValueForKey:key] source]]];
        parameterDict[key] = valueDict;
      }
    }
    result(parameterDict);
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    NSDictionary *defaults = call.arguments[@"defaults"];
    [remoteConfig setDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] setValue:[defaults allKeys] forKey:@"default_keys"];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (int)mapLastFetchStatus:(FIRRemoteConfigFetchStatus)status {
  if (status == FIRRemoteConfigFetchStatusSuccess) {
    return 0;
  } else if (status == FIRRemoteConfigFetchStatusFailure) {
    return 1;
  } else if (status == FIRRemoteConfigFetchStatusThrottled) {
    return 2;
  } else if (status == FIRRemoteConfigFetchStatusNoFetchYet) {
    return 3;
  } else {
    return 1;
  }
}

- (int)mapValueSource:(FIRRemoteConfigSource)source {
  if (source == FIRRemoteConfigSourceStatic) {
    return 0;
  } else if (source == FIRRemoteConfigSourceDefault) {
    return 1;
  } else if (source == FIRRemoteConfigSourceRemote) {
    return 2;
  } else {
    return 0;
  }
}

@end
