#import <Foundation/Foundation.h>

@interface E2EIosTest : NSObject

- (BOOL)testE2E:(NSString **)testResult;

@end

#define E2E_IOS_RUNNER(__test_class)                    \
  @interface __test_class : XCTestCase                  \
  @end                                                  \
                                                        \
  @implementation __test_class                          \
                                                        \
  -(void)testE2E {                                      \
    NSString *testResult;                               \
    E2EIosTest *e2eIosTest = [[E2EIosTest alloc] init]; \
    BOOL testPass = [e2eIosTest testE2E:&testResult];   \
    XCTAssertTrue(testPass, @"%@", testResult);         \
  }                                                     \
                                                        \
  @end
