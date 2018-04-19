#import "FirebasePerformancePlugin.h"

#import "Firebase/Firebase.h"

@implementation FirebasePerformancePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/firebase_performance"
            binaryMessenger:[registrar messenger]];
  FirebasePerformancePlugin* instance = [[FirebasePerformancePlugin alloc] init];
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
  if ([@"FirebasePerformance#isPerformanceCollectionEnabled" isEqualToString:call.method]) {
    result(@([[FIRPerformance sharedInstance] isDataCollectionEnabled]));
  } else if ([@"FirebasePerformance#setPerformanceCollectionEnabled" isEqualToString:call.method]) {
    NSNumber *enable = call.arguments;
    [[FIRPerformance sharedInstance] setDataCollectionEnabled:[enable boolValue]];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
