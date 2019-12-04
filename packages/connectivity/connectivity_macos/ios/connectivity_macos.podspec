#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'connectivity_macos'
  s.version          = '0.0.1'
  s.summary          = 'No-op implementation of the connectivity desktop plugin to avoid build issues on iOS'
  s.description      = <<-DESC
  No-op implementation of connectivity_macos to avoid build issues on iOS.
  See https://github.com/flutter/flutter/issues/39659
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/connectivity/connectivity_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end