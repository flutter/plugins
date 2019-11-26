#import "EspressoPlugin.h"
#if __has_include(<espresso/espresso-Swift.h>)
#import <espresso/espresso-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "espresso-Swift.h"
#endif

@implementation EspressoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEspressoPlugin registerWithRegistrar:registrar];
}
@end
