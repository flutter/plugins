#import "E2EIosTest.h"
#import "E2EPlugin.h"

@implementation E2EIosTest

- (BOOL)testE2E:(NSString **)testResult {
  E2EPlugin *e2ePlugin = [E2EPlugin instance];
  while (!e2ePlugin.testResults) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.f, NO);
  }
  NSDictionary<NSString *, NSString *> *testResults = e2ePlugin.testResults;
  NSMutableArray<NSString *> *passedTests = [NSMutableArray array];
  NSMutableArray<NSString *> *failedTests = [NSMutableArray array];
  NSLog(@"==================== Test Results =====================");
  for (NSString *test in testResults.allKeys) {
    NSString *result = testResults[test];
    if ([result isEqualToString:@"success"]) {
      NSLog(@"%@ passed.", test);
      [passedTests addObject:test];
    } else {
      NSLog(@"%@ failed.", test);
      [failedTests addObject:test];
    }
  }
  NSLog(@"================== Test Results End ====================");
  BOOL testPass = failedTests.count == 0;
  if (!testPass && testResult) {
    *testResult =
        [NSString stringWithFormat:@"Detected failed E2E test(s) %@ among %@",
                                   failedTests.description, testResults.allKeys.description];
  }
  return testPass;
}

@end
