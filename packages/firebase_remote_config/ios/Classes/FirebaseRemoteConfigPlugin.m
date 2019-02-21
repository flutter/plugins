#import "FirebaseRemoteConfigPlugin.h"

#import <Firebase/Firebase.h>

@interface FirebaseRemoteConfigPlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseRemoteConfigPlugin

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
    if (![FIRApp appNamed:@"__FIRAPP_DEFAULT"]) {
      NSLog(@"Configuring the default Firebase app...");
      [FIRApp configure];
      NSLog(@"Configured the default Firebase app %@.", [FIRApp defaultApp].name);
    }
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"RemoteConfig#instance" isEqualToString:call.method]) {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    FIRRemoteConfigSettings *firRemoteConfigSettings = [remoteConfig configSettings];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];

    resultDict[@"lastFetchTime"] = [[NSNumber alloc]
        initWithLong:(long)[[remoteConfig lastFetchTime] timeIntervalSince1970] * 1000];
    resultDict[@"lastFetchStatus"] =
        [self mapLastFetchStatus:(FIRRemoteConfigFetchStatus)[remoteConfig lastFetchStatus]];
    resultDict[@"inDebugMode"] =
        [[NSNumber alloc] initWithBool:[firRemoteConfigSettings isDeveloperModeEnabled]];

    resultDict[@"parameters"] = [self getConfigParameters];

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
                    NSString *lastFetchStatus =
                        [self mapLastFetchStatus:(FIRRemoteConfigFetchStatus)[remoteConfig
                                                                                  lastFetchStatus]];
                    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
                    resultDict[@"lastFetchTime"] = lastFetchTime;
                    resultDict[@"lastFetchStatus"] = lastFetchStatus;

                    if (status != FIRRemoteConfigFetchStatusSuccess) {
                      FlutterError *flutterError;
                      if (status == FIRRemoteConfigFetchStatusThrottled) {
                        int mills =
                            [[error.userInfo
                                valueForKey:FIRRemoteConfigThrottledEndTimeInSecondsKey] intValue] *
                            1000;
                        resultDict[@"fetchThrottledEnd"] = [[NSNumber alloc] initWithInt:mills];
                        NSString *errorMessage =
                            @"Fetch has been throttled. See the error's fetchThrottledEnd "
                             "field for throttle end time.";
                        flutterError = [FlutterError errorWithCode:@"fetchFailedThrottled"
                                                           message:errorMessage
                                                           details:resultDict];
                      } else {
                        NSString *errorMessage = @"Unable to complete fetch. Reason is unknown "
                                                  "but this could be due to lack of connectivity.";
                        flutterError = [FlutterError errorWithCode:@"fetchFailed"
                                                           message:errorMessage
                                                           details:resultDict];
                      }
                      result(flutterError);
                    } else {
                      result(resultDict);
                    }
                  }];
  } else if ([@"RemoteConfig#activate" isEqualToString:call.method]) {
    BOOL newConfig = [[FIRRemoteConfig remoteConfig] activateFetched];
    NSDictionary *parameters = [self getConfigParameters];
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    resultDict[@"newConfig"] = [NSNumber numberWithBool:newConfig];
    resultDict[@"parameters"] = parameters;
    result(resultDict);
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
  valueDict[@"source"] = [self mapValueSource:[remoteConfigValue source]];
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
