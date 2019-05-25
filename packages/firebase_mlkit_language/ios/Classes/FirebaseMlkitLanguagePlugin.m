#import "FirebaseMlkitLanguagePlugin.h"

static FlutterError *getFlutterError(NSError *error) {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

@implementation FLTFirebaseMlkitLanguagePlugin

+ (void)handleError:(NSError *)error result:(FlutterResult)result {
  result(getFlutterError(error));
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"firebase_mlkit_language"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMlkitLanguagePlugin *instance = [[FLTFirebaseMlkitLanguagePlugin alloc] init];
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
  NSString *modelname = call.arguments[@"model"];
  NSString *text = call.arguments[@"text"];
  NSDictionary *options = call.arguments[@"options"];
  if ([@"LanguageIdentifier#processText" isEqualToString:call.method]) {
    [LanguageIdentifier handleEvent:text options:options result:result];
  } else if ([@"LanguageTranslator#processText" isEqualToString:call.method]) {
    [LanguageTranslator handleEvent:text options:options result:result];
  } else if ([@"ModelManager#viewModels" isEqualToString:call.method]) {
    [ViewModels result:result];
  } else if ([@"ModelManager#deleteModel" isEqualToString:call.method]) {
    [DeleteModel handleEvent:modelname result:result];
  } else if ([@"ModelManager#downloadModel" isEqualToString:call.method]) {
    [DownloadModel handleEvent:modelname result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
