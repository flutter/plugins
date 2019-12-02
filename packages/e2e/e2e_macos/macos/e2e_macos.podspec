#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'e2e_macos'
  s.version          = '0.0.1'
  s.summary          = 'Adapter for e2e tests.'
  s.description      = <<-DESC
Runs tests that use the flutter_test API as integration tests on macOS.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/e2e/e2e_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end

