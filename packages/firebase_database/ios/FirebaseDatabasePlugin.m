#import "FirebaseDatabasePlugin.h"

#import <Firebase/Firebase.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end

FIRDatabaseReference *getReference(NSDictionary *arguments) {
  NSString *path = arguments[@"path"];
  FIRDatabaseReference *ref = [FIRDatabase database].reference;
  if ([path length] > 0) ref = [ref child:path];
  return ref;
}

FIRDataEventType parseEventType(NSString *eventTypeString) {
  if ([@"_EventType.childAdded" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildAdded;
  } else if ([@"_EventType.childRemoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildRemoved;
  } else if ([@"_EventType.childChanged" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildChanged;
  } else if ([@"_EventType.childMoved" isEqual:eventTypeString]) {
    return FIRDataEventTypeChildMoved;
  } else if ([@"_EventType.value" isEqual:eventTypeString]) {
    return FIRDataEventTypeValue;
  }
  assert(false);
  return 0;
}

@interface FirebaseDatabasePlugin ()
@property(nonatomic, retain) FlutterMethodChannel *channel;
@end

@implementation FirebaseDatabasePlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_database"
                                  binaryMessenger:[registrar messenger]];
  FirebaseDatabasePlugin *instance = [[FirebaseDatabasePlugin alloc] init];
  instance.channel = channel;
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

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  void (^defaultCompletionBlock)(NSError *, FIRDatabaseReference *) =
      ^(NSError *error, FIRDatabaseReference *ref) {
        result(error.flutterError);
      };
  if ([@"DatabaseReference#set" isEqualToString:call.method]) {
    [getReference(call.arguments) setValue:call.arguments[@"value"]
                       withCompletionBlock:defaultCompletionBlock];
  } else if ([@"Query#observe" isEqualToString:call.method]) {
    FIRDataEventType eventType = parseEventType(call.arguments[@"eventType"]);
    __block FIRDatabaseHandle handle = [getReference(call.arguments)
                      observeEventType:eventType
        andPreviousSiblingKeyWithBlock:^(FIRDataSnapshot *snapshot, NSString *previousSiblingKey) {
          [self.channel invokeMethod:@"Event"
                           arguments:@{
                             @"handle" : [NSNumber numberWithUnsignedInteger:handle],
                             @"snapshot" : @{
                               @"key" : snapshot.key ?: [NSNull null],
                               @"value" : snapshot.value ?: [NSNull null],
                             },
                             @"previousSiblingKey" : previousSiblingKey ?: [NSNull null],
                           }];
        }];
    result([NSNumber numberWithUnsignedInteger:handle]);
  } else if ([@"Query#removeObserver" isEqualToString:call.method]) {
    FIRDatabaseHandle handle = [call.arguments[@"handle"] unsignedIntegerValue];
    [getReference(call.arguments) removeObserverWithHandle:handle];
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
