#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Provide the GoogleMaps API key.
  [GMSServices provideAPIKey:@"AIzaSyCkn-k1liMviBz4xVzOTt5kHzz9G4xXrwg"];

  // Register Flutter plugins.
  [GeneratedPluginRegistrant registerWithRegistry:self];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
