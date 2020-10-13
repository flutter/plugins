@import camera;
@import XCTest;

@interface CameraPluginTests : XCTestCase
@end

@implementation CameraPluginTests

- (void)testModuleImport {
  // This test will fail to compile if the module cannot be imported.
  // Make sure this plugin supports modules. See https://github.com/flutter/flutter/issues/41007.
  // If not already present, add this line to the podspec:
  // s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
}

@end
