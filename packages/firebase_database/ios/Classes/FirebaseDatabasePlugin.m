#import "FirebaseDatabasePlugin.h"

#import <Firebase/Firebase.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError
      errorWithCode:[NSString stringWithFormat:@"Error %ld", self.code]
            message:self.domain
            details:self.localizedDescription];
}
@end

@implementation FirebaseDatabasePlugin {
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
  [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_database"
                              binaryMessenger:[registrar messenger]];
  FirebaseDatabasePlugin *instance = [[FirebaseDatabasePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
  // TODO(jackson): stub code that should be replaced with dynamic registration.
  [[[FIRDatabase database].reference queryLimitedToLast:10]
      observeEventType:FIRDataEventTypeChildAdded
             withBlock:^(FIRDataSnapshot *_Nonnull snapshot) {
               [channel invokeMethod:@"DatabaseReference#childAdded"
                           arguments:@[ snapshot.key, snapshot.value ]];
             }];
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
  if ([@"DatabaseReference#set" isEqualToString:call.method]) {
    NSDictionary *data = call.arguments[0];
    FIRDatabaseReference *ref =
        [[FIRDatabase database].reference childByAutoId];
    [ref updateChildValues:data
        withCompletionBlock:^(NSError *_Nullable error,
                              FIRDatabaseReference *_Nonnull ref) {
          if (error != nil) {
            result(error.flutterError);
          } else {
            result(nil);
          }
        }];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
