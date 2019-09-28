#import "InstrumentationAdapterPlugin.h"

IAPTestResult const IAPTestResultSuccess = @"success";

@interface InstrumentationAdapterPlugin ()
@property (copy, readwrite, nullable) NSDictionary<NSString*, IAPTestResult>* testResultsByDescription;
@end

@implementation InstrumentationAdapterPlugin

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
  InstrumentationAdapterPlugin* instance = self.sharedInstance;
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"allTestsFinished"]) {
    NSDictionary<NSString*, IAPTestResult>* arguments = [call arguments];
    self.testResultsByDescription = arguments;
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
