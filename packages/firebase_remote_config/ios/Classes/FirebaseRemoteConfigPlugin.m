#import "FirebaseRemoteConfigPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseRemoteConfigPlugin

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

    resultDict[LAST_FETCH_TIME_KEY] = [[NSNumber alloc]
        initWithLong:(long)[[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000];
    resultDict[LAST_FETCH_STATUS_KEY] = [[NSNumber alloc]
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
                    resultDict[LAST_FETCH_TIME_KEY] = lastFetchTime;
                    resultDict[LAST_FETCH_STATUS_KEY] = lastFetchStatus;

                    if (status != FIRRemoteConfigFetchStatusSuccess) {
                      FlutterError *flutterError;
                      if (status == FIRRemoteConfigFetchStatusThrottled) {
                        int mills =
                            [[error.userInfo
                                valueForKey:FIRRemoteConfigThrottledEndTimeInSecondsKey] intValue] *
                            1000;
                        resultDict[@"FETCH_THROTTLED_END"] = [[NSNumber alloc] initWithInt:mills];
                        NSString *errorMessage =
                            @"Fetch has been throttled. See the error's FETCH_THROTTLED_END "
                             "field for throttle end time.";
                        flutterError = [FlutterError errorWithCode:@"FETCH_FAILED_THROTTLED"
                                                           message:errorMessage
                                                           details:resultDict];
                      } else {
                        NSString *errorMessage =
                            @"Unable to complete fetch. Reason is unknown "
                             "but this could be due to lack of connectivity.";
                        flutterError = [FlutterError errorWithCode:@"FETCH_FAILED"
                                                           message:errorMessage
                                                           details:resultDict];
                      }
                      result(flutterError);
                    } else {
                      result(resultDict);
                    }
                  }];
  } else if ([@"RemoteConfig#activate" isEqualToString:call.method]) {
    bool newConfig = [[FIRRemoteConfig remoteConfig] activateFetched];
    NSDictionary *parameters = [self getConfigParameters];
    result(@{@"newConfig" : [[NSNumber init] initWithBool:newConfig], @"parameters" : parameters});
  } else if ([@"RemoteConfig#setDefaults" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    NSDictionary *defaults = call.arguments[@"defaults"];
    [remoteConfig setDefaults:defaults];
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
  NSArray *defaultKeys = [remoteConfig allKeysFromSource:FIRRemoteConfigSourceDefault
                                               namespace:FIRNamespaceGoogleMobilePlatform];
  for (NSString *key in defaultKeys) {
    if ([parameterDict valueForKey:key] == nil) {
      parameterDict[key] = [self createRemoteConfigValueDict:[remoteConfig configValueForKey:key]];
    }
  }
  return parameterDict;
}

- (NSString *)mapLastFetchStatus:(FIRRemoteConfigFetchStatus)status {
  if (status == FIRRemoteConfigFetchStatusSuccess) {
    return @"success";
  } else if (status == FIRRemoteConfigFetchStatusFailure) {
    return @"failure";
  } else if (status == FIRRemoteConfigFetchStatusThrottled) {
    return @"throttled";
  } else if (status == FIRRemoteConfigFetchStatusNoFetchYet) {
    return @"noFetchYet";
  } else {
    return @"failure";
  }
}

- (NSString *)mapValueSource:(FIRRemoteConfigSource)source {
  if (source == FIRRemoteConfigSourceStatic) {
    return @"static";
  } else if (source == FIRRemoteConfigSourceDefault) {
    return @"default";
  } else if (source == FIRRemoteConfigSourceRemote) {
    return @"remote";
  } else {
    return @"static";
  }
}

@end
