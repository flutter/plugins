#import "E2EIosTest.h"
#import "E2EPlugin.h"

@implementation E2EIosTestResult

- (instancetype)initWithTestCase:(NSString *)testCase withResult:(NSString *)result {
  self = [super init];
  if (self) {
    _testCase = testCase;
    _result = result;
  }
  return self;
}

@end

static SEL AddTestCase(Class xcTestCase, NSString *name) {
  SEL methodSelector = NSSelectorFromString(name);
  Method realMethod = class_getInstanceMethod(xcTestCase, @selector(printTestResult));
  IMP realImp = method_getImplementation(realMethod);
  struct objc_method_description *desc = method_getDescription(realMethod);
  class_addMethod(xcTestCase, methodSelector, realImp, desc->types);
  return methodSelector;
}

NSArray<NSInvocation *> *E2EMakeTestInvocations(Class xcTestCase) {
  NSMutableDictionary<NSString *, E2EIosTestResult *> *results = [@{} mutableCopy];
  E2EPlugin *e2ePlugin = [E2EPlugin instance];
  UIViewController *rootViewController =
      [[[[UIApplication sharedApplication] delegate] window] rootViewController];
  if (![rootViewController isKindOfClass:[FlutterViewController class]]) {
    NSLog(@"expected FlutterViewController as rootViewController.");
    return @[];
  }
  FlutterViewController *flutterViewController = (FlutterViewController *)rootViewController;
  [e2ePlugin setupChannels:flutterViewController.engine.binaryMessenger];
  while (!e2ePlugin.testResults) {
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.f, NO);
  }
  NSCharacterSet *whiteSpaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
  NSMutableArray<NSInvocation *> *invocations = [@[] mutableCopy];
  for (NSString *testCase in e2ePlugin.testResults.allKeys) {
    NSString *formattedTestCase = [[testCase stringByTrimmingCharactersInSet:whiteSpaceSet]
        stringByReplacingOccurrencesOfString:@" "
                                  withString:@"_"];
    results[formattedTestCase] =
        [[E2EIosTestResult alloc] initWithTestCase:testCase
                                        withResult:e2ePlugin.testResults[testCase]];
    SEL testSelector = AddTestCase(xcTestCase, formattedTestCase);
    NSMethodSignature *signature = [xcTestCase instanceMethodSignatureForSelector:testSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = testSelector;
    [invocations addObject:invocation];
  }
  objc_setAssociatedObject(xcTestCase, @selector(printTestResult), results,
                           OBJC_ASSOCIATION_RETAIN);
  return invocations;
}
