#import <Flutter/Flutter.h>

@interface FirebasePerformancePlugin : NSObject<FlutterPlugin>
// Handles are ints used as indexes into the dictionary of active traces
@property(readonly) int nextHandleTrace;
@property(readonly) NSMutableDictionary *traces;
@end
