#import "InstrumentationAdapterPlugin.h"

@implementation InstrumentationAdapterPlugin
{
    NSMutableDictionary *testResults;
};

+ (instancetype)sharedInstance  {
    static InstrumentationAdapterPlugin *singleton;
    dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        singleton = [[InstrumentationAdapterPlugin alloc] init];
    });
    return singleton;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"dev.flutter/InstrumentationAdapterFlutterBinding"
            binaryMessenger:[registrar messenger]];
  InstrumentationAdapterPlugin* instance = [InstrumentationAdapterPlugin sharedInstance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"allTestsFinished" isEqualToString:call.method]) {
      NSDictionary *arguments = [call arguments];
      testResults = arguments[@"results"];
      result(nil);
      NSLog(@"debug all test done!!!!!!!!!!!!!!!!");
      NSLog(@"%@", testResults);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSDictionary *)getTestResults {
    return testResults;
}

@end
