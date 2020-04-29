#import "PathProviderLinuxPlugin.h"
#if __has_include(<path_provider_linux/path_provider_linux-Swift.h>)
#import <path_provider_linux/path_provider_linux-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "path_provider_linux-Swift.h"
#endif

@implementation PathProviderLinuxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPathProviderLinuxPlugin registerWithRegistrar:registrar];
}
@end
