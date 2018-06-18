#import "FirebaseMlVisionPlugin.h"

#import "Firebase/Firebase.h"

@implementation FirebaseMlVisionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_ml_vision"
                                  binaryMessenger:[registrar messenger]];
  FirebaseMlVisionPlugin* instance = [[FirebaseMlVisionPlugin alloc] init];
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
  if ([@"TextDetector#detectInImage" isEqualToString:call.method]) {
    result(@[]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
