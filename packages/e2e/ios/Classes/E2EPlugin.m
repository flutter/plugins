#import "E2EPlugin.h"

static NSString *const kE2EPluginChannel = @"plugins.flutter.io/e2e";
static NSString *const kMethodTestFinished = @"allTestsFinished";

@interface E2EPlugin ()

@property(nonatomic, readwrite) NSDictionary<NSString *, NSString *> *testResults;

@end

@implementation E2EPlugin {
  NSDictionary<NSString *, NSString *> *_testResults;
}

+ (E2EPlugin *)instance {
  static dispatch_once_t onceToken;
  static E2EPlugin *sInstance;
  dispatch_once(&onceToken, ^{
    sInstance = [[E2EPlugin alloc] initForRegistration];
  });
  return sInstance;
}

- (instancetype)initForRegistration {
  return [super init];
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kE2EPluginChannel
                                                              binaryMessenger:registrar.messenger];
  [registrar addMethodCallDelegate:[E2EPlugin instance] channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([kMethodTestFinished isEqual:call.method]) {
    self.testResults = call.arguments[@"results"];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
