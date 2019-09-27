#import <Flutter/Flutter.h>

@interface InstrumentationAdapterPlugin : NSObject <FlutterPlugin>

+ (instancetype)sharedInstance;

- (NSDictionary *)getTestResults;

@end

