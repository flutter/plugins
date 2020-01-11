#import "CustomCursorPlugin.h"
#if __has_include(<custom_cursor/custom_cursor-Swift.h>)
#import <custom_cursor/custom_cursor-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "custom_cursor-Swift.h"
#endif

@implementation CustomCursorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCustomCursorPlugin registerWithRegistrar:registrar];
}
@end
