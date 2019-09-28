#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString* IAPTestResult NS_TYPED_EXTENSIBLE_ENUM;

/// Success string from underlying tests.
extern IAPTestResult const IAPTestResultSuccess;

@interface InstrumentationAdapterPlugin : NSObject <FlutterPlugin>

@property (class, readonly) InstrumentationAdapterPlugin* sharedInstance;

/// Set when the underlying tests are complete.
@property (copy, readonly, nullable) NSDictionary<NSString*, IAPTestResult>* testResultsByDescription;

@end

NS_ASSUME_NONNULL_END
