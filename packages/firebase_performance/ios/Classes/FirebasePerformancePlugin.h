#import <Firebase/Firebase.h>
#import <Flutter/Flutter.h>

@interface FLTFirebasePerformancePlugin : NSObject <FlutterPlugin>
@end

@interface FLTFirebasePerformance : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithMessenger:(NSObject<FlutterBinaryMessenger> *_Nonnull)messenger;
@end

@interface FLTTrace : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithTrace:(FIRTrace *_Nonnull)trace;
@end

@interface FLTHttpMetric : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithHttpMetric:(FIRHTTPMetric *_Nonnull)metric;
@end
