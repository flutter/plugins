#import <EarlGrey/EarlGrey.h>

#import "OSTesterPlugin.h"

static FlutterError *getFlutterError(NSError *error) {
  if (error == nil) return nil;
  
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", error.code]
                             message:error.domain
                             details:error.localizedDescription];
}

static id<GREYMatcher> getMatcher(NSDictionary *data) {
  NSString *label = data[@"label"];
  if (label != nil) {
    return grey_accessibilityLabel(label);
  }
  NSString *text = data[@"text"];
  if (text != nil) {
      return grey_text(text);
  }
  NSNumber *visible = data[@"visible"];
  if (visible != nil) {
    return grey_sufficientlyVisible();
  }
  NSLog(@"Matcher not implemented: %@", data);
  return nil;
}

@implementation OSTesterPlugin {
  FlutterMethodChannel* channel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.flutter.io/os_tester"
            binaryMessenger:[registrar messenger]];
  OSTesterPlugin* instance = [[OSTesterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  id<GREYMatcher> matcher = getMatcher(call.arguments[@"matcher"]);
  if ([@"tap" isEqualToString:call.method]) {
    __block NSError *error;
    BOOL success = [[GREYCondition conditionWithName:call.method
                                               block:^{
                                                 [[EarlGrey selectElementWithMatcher:matcher] performAction:grey_tap() error:&error];
                                                 if (error == nil) {
                                                   return YES;
                                                 } else {
                                                   return NO;
                                                 }
                                               }] waitWithTimeout:5];
    if (success) {
      result(nil);
    } else {
      result(getFlutterError(error));
    }
  } else if ([@"expect" isEqualToString:call.method]) {
    [[GREYCondition conditionWithName:call.method
                                block:^{
                                  NSError *error;
                                  id<GREYMatcher> actual = getMatcher(call.arguments[@"actual"]);
                                  [[EarlGrey selectElementWithMatcher:actual] assertWithMatcher:matcher error:&error];
                                  if (error == nil) {
                                    result(nil);
                                    return YES;
                                  } else {
                                    return NO;
                                  }
                                }] waitWithTimeout:5];
  } else {
    result(FlutterMethodNotImplemented);
    return;
  }
}

- (void)handleException:(GREYFrameworkException *)ex details:(NSString *)details {
  // TODO(jackson): Possibly not necessary if we use &error consistently above?
  //  [FlutterError errorWithCode:ex.name message:ex.reason details:details];
}

- (void)setInvocationFile:(NSString *)fileName
        andInvocationLine:(NSUInteger)lineNumber {
  // TODO(jackson): Record the file name and line number of the statement
  // that was executing before the failure occurred.
}

@end
