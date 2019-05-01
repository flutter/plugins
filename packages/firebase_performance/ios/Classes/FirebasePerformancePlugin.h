#import <Firebase/Firebase.h>
#import <Flutter/Flutter.h>

@interface FLTFirebasePerformancePlugin : NSObject <FlutterPlugin>
+ (void)addMethodHandler:(NSNumber *_Nonnull)handle methodHandler:(id<FlutterPlugin>_Nonnull)handler;
+ (void)removeMethodHandler:(NSNumber *_Nonnull)handle;
@end

@interface FLTFirebasePerformance : NSObject<FlutterPlugin>
+ (void)sharedInstanceWithCall:(FlutterMethodCall *_Nonnull)call result:(FlutterResult _Nonnull)result;
@end

@interface FLTTrace : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithTrace:(FIRTrace *_Nonnull)trace;
@end

@interface FLTHttpMetric : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *_Nonnull)metric;
@end
