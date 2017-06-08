#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  CallbackPlugin *plugin = (CallbackPlugin *)[self valuePublishedByPlugin:@"CallbackPlugin"];
  [plugin registerCallback:^{
    NSLog(@"Hello world!!");
  } withId:@"hello_world"];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
