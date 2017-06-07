#import <Flutter/Flutter.h>

@interface QuickActionsPlugin : NSObject<FlutterPlugin>

// Handles the Home screen quick action for your app that the user selected.
- (void)performActionForShortcutItem:(UIApplicationShortcutItem *)item;
@end
