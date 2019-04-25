#import <Firebase/Firebase.h>
#import <Flutter/Flutter.h>

@interface FLTFirebasePerformancePlugin : NSObject <FlutterPlugin>
@end

@interface FLTFirebasePerformance : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar;
@end

@interface FLTTrace : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithTrace:(FIRTrace *_Nonnull)trace
                             registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar
                               channel:(FlutterMethodChannel *_Nonnull)channel;
@end

@interface FLTHttpMetric : NSObject<FlutterPlugin>
- (instancetype _Nonnull)initWithHTTPMetric:(FIRHTTPMetric *_Nonnull)metric
                                  registrar:(NSObject<FlutterPluginRegistrar> *_Nonnull)registrar
                                    channel:(FlutterMethodChannel *_Nonnull)channel;
@end
