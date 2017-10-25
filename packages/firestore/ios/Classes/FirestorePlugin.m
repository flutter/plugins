#import "FirestorePlugin.h"
#import <firestore/firestore-Swift.h>

@implementation FirestorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFirestorePlugin registerWithRegistrar:registrar];
}
@end
