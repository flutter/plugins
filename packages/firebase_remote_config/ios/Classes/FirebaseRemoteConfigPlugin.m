#import "FirebaseRemoteConfigPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseRemoteConfigPlugin

static NSString *DEFAULT_KEYS = @"default_keys";
static NSString *LAST_FETCH_TIME_KEY = @"LAST_FETCH_TIME";
static NSString *LAST_FETCH_STATUS_KEY = @"LAST_FETCH_STATUS";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_remote_config"
                                  binaryMessenger:[registrar messenger]];
  FirebaseRemoteConfigPlugin *instance = [[FirebaseRemoteConfigPlugin alloc] init];
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

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"RemoteConfig#instance" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *firRemoteConfigSettings = [remoteConfig configSettings];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];

    resultDict[@"LAST_FETCH_TIME"] = [[NSNumber alloc]
        initWithLong:(long)[[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000];
    resultDict[@"LAST_FETCH_STATUS"] = [[NSNumber alloc]
        initWithInt:[self mapLastFetchStatus:(FIRRemoteConfigFetchStatus)[remoteConfig
                                                                              lastFetchStatus]]];
    resultDict[@"IN_DEBUG_MODE"] =
        [[NSNumber alloc] initWithBool:[firRemoteConfigSettings isDeveloperModeEnabled]];

    resultDict[@"PARAMETERS", [self getConfigParameters]];

    result(resultDict);
  } else if ([@"RemoteConfig#setConfigSettings" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    bool debugMode = (bool)call.arguments[@"debugMode"];
    FIRRemoteConfigSettings *remoteConfigSettings =
        [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:debugMode];
    [remoteConfig setConfigSettings:remoteConfigSettings];
    result(nil);
  } else if ([@"RemoteConfig#fetch" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    long expiration = (long)call.arguments[@"expiration"];

    [remoteConfig
        fetchWithExpirationDuration:expiration
                  completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
                    NSNumber *lastFetchTime = [[NSNumber alloc]
                        initWithLong:(long)[[remoteConfig lastFetchTime] timeIntervalSince1970] *
                            1000];
                    NSNumber *lastFetchStatus = [[NSNumber alloc]
                        initWithInt:[self mapLastFetchStatus:(FIRRemoteConfigFetchStatus)
                            [remoteConfig lastFetchStatus]]];
                    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
                    resultDict[@"LAST_FETCH_TIME"] = lastFetchTime;
                    resultDict[@"LAST_FETCH_STATUS"] = lastFetchStatus;

                    if (status != FIRRemoteConfigFetchStatusSuccess) {
                      FlutterError *flutterError;
                      if (status == FIRRemoteConfigFetchStatusThrottled) {
                        int mills = [[error.userInfo valueForKey: FIRRemoteConfigThrottledEndTimeInSecondsKey] intValue] * 1000;
                        resultDict[@"FETCH_THROTTLED_END"] = [[NSNumber alloc] initWithInt:mills];
                        flutterError = [FlutterError errorWithCode:@"FETCH_FAILED_THROTTLED"
                                                           message:nil
                                                           details:resultDict];
                      } else {
                        flutterError = [FlutterError errorWithCode:@"FETCH_FAILED"
                                                           message:nil
                                                           details:resultDict];
                      }
                      result(flutterError);
                    } else {
                      result(resultDict);
                    }
                  }];
  } else if ([@"RemoteConfig#activate" isEqualToString:call.method]) {
    [[FIRRemoteConfig remoteConfig] activateFetched];
    result([self getConfigParameters]);
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    NSDictionary *defaults = call.arguments[@"defaults"];
    [remoteConfig setDefaults:defaults];
    [[NSUserDefaults standardUserDefaults] setValue:[defaults allKeys] forKey:DEFAULT_KEYS];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSMutableDictionary *)createRemoteConfigValueDict:(FIRRemoteConfigValue *)remoteConfigValue {
  NSMutableDictionary *valueDict = [[NSMutableDictionary alloc] init];
  valueDict[@"value"] = [FlutterStandardTypedData typedDataWithBytes:[remoteConfigValue dataValue]];
  valueDict[@"source"] =
      [[NSNumber alloc] initWithInt:[self mapValueSource:[remoteConfigValue source]]];
  return valueDict;
}

- (NSDictionary *)getConfigParameters {
  FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
  NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc] init];
  NSSet *keySet = [remoteConfig keysWithPrefix:@""];
  for (NSString *key in keySet) {
    parameterDict[key] = [self createRemoteConfigValueDict:[remoteConfig configValueForKey:key]];
  }
  // Add default parameters if missing since `keysWithPrefix` does not return default keys.
  NSArray *defaultKeys = [[NSUserDefaults standardUserDefaults] arrayForKey:DEFAULT_KEYS];
  for (NSString *key in defaultKeys) {
    if ([parameterDict valueForKey:key] == nil) {
      parameterDict[key] =
          [self createRemoteConfigValueDict:[remoteConfig configValueForKey:key]];
    }
  }
  return parameterDict;
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
