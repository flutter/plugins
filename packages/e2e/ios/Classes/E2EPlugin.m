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
  // No initialization happens here because of the way XCTest loads the testing
  // bundles.  Setup on static variables can be disregarded when a new static
  // instance of E2EPlugin is allocated when the bundle is reloaded.
  // See also: https://github.com/flutter/plugins/pull/2465
}

- (void)setupChannels:(id<FlutterBinaryMessenger>)binaryMessenger {
  FlutterMethodChannel *channel = [FlutterMethodChannel methodChannelWithName:kE2EPluginChannel
                                                              binaryMessenger:binaryMessenger];
  [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
    [self handleMethodCall:call result:result];
  }];
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
