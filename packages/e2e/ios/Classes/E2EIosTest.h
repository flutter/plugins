#import <Foundation/Foundation.h>
#include <objc/runtime.h>

@interface E2EIosTestResult : NSObject

@property(nonatomic, readonly) NSString *testCase;

@property(nonatomic, readonly) NSString *result;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithTestCase:(NSString *)testCase withResult:(NSString *)result;

@end

NSArray<NSInvocation *> *E2EMakeTestInvocations(Class xcTestCase);

#define E2E_IOS_RUNNER(__test_class)                                                   \
  @interface __test_class : XCTestCase                                                 \
  @end                                                                                 \
                                                                                       \
  @implementation __test_class                                                         \
                                                                                       \
  +(NSArray<NSInvocation *> *)testInvocations {                                        \
    return E2EMakeTestInvocations([self class]);                                       \
  }                                                                                    \
                                                                                       \
  -(void)printTestResult {                                                             \
    NSDictionary<NSString *, E2EIosTestResult *> *results =                            \
        objc_getAssociatedObject([self class], @selector(printTestResult));            \
    E2EIosTestResult *testResult = results[NSStringFromSelector(_cmd)];                \
    if (![testResult.result isEqualToString:@"success"]) {                             \
      XCTFail("'%@' failed with message: %@", testResult.testCase, testResult.result); \
    }                                                                                  \
  }                                                                                    \
                                                                                       \
  @end
