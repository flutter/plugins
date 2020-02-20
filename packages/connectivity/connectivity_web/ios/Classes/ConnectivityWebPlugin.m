#import "ConnectivityWebPlugin.h"
#if __has_include(<connectivity_web/connectivity_web-Swift.h>)
#import <connectivity_web/connectivity_web-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "connectivity_web-Swift.h"
#endif

@implementation ConnectivityWebPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftConnectivityWebPlugin registerWithRegistrar:registrar];
}
@end
