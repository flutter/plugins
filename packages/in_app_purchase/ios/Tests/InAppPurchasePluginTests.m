@import in_app_purchase;
@import XCTest;

@interface InAppPurchasePluginTests : XCTestCase
@end

@implementation InAppPurchasePluginTests

- (void)testModuleImport {
  // This test will fail to compile if the module cannot be imported.
  // Make sure this plugin supports modules. See https://github.com/flutter/flutter/issues/41007.
  // If not already present, add this line to the podspec:
  // s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
}

@end
