#import "DeviceInfoPlugin.h"

@interface FLTDeviceInfoPlugin ()
- (NSString*)isDevicePhysical;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@end
