#import "FlutterAndroidLifecyclePlugin.h"
#import <flutter_android_lifecycle/flutter_android_lifecycle-Swift.h>

@implementation FlutterAndroidLifecyclePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAndroidLifecyclePlugin registerWithRegistrar:registrar];
}
@end
