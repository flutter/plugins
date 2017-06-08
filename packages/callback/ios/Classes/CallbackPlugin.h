#import <Flutter/Flutter.h>

@interface CallbackPlugin : NSObject<FlutterPlugin>

- (void)registerCallback:(void (^)())callback withId:(NSString*)id;
@end
