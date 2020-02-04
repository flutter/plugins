#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

/** A Flutter plugin that's responsible for communicating the test results back to iOS XCTest. */
@interface E2EPlugin : NSObject <FlutterPlugin>

/**
 * Test results that are sent from Dart when E2E test completes. Before the completion, it is
 * @c nil.
 */
@property(nonatomic, readonly, nullable) NSDictionary<NSString *, NSString *> *testResults;

/** Fetches the singleton instance of the plugin. */
+ (E2EPlugin *)instance;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
