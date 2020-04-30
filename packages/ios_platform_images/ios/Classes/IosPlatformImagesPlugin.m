#import "IosPlatformImagesPlugin.h"

#if !__has_feature(objc_arc)
#error ARC must be enabled!
#endif

@interface IosPlatformImagesPlugin ()
@end

@implementation IosPlatformImagesPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/ios_platform_images"
                                  binaryMessenger:[registrar messenger]];

  [channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    if ([@"loadImage" isEqualToString:call.method]) {
      NSString* name = call.arguments;
      UIImage* image = [UIImage imageNamed:name];
      NSData* data = UIImagePNGRepresentation(image);
      if (data) {
        result(@{
          @"scale" : @(image.scale),
          @"data" : [FlutterStandardTypedData typedDataWithBytes:data],
        });
      } else {
        result(nil);
      }
      return;
    } else if ([@"resolveURL" isEqualToString:call.method]) {
      NSArray* args = call.arguments;
      NSString* name = args[0];
      NSString* extension = (args[1] == (id)NSNull.null) ? nil : args[1];

      NSURL* url = [[NSBundle mainBundle] URLForResource:name withExtension:extension];
      result(url.absoluteString);
      return;
    }
    result(FlutterMethodNotImplemented);
  }];
}

@end
