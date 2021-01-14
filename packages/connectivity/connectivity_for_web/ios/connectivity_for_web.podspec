#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint connectivity_web.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'connectivity_for_web'
  s.version          = '0.1.0'
  s.summary          = 'No-op implementation of connectivity web plugin to avoid build issues on iOS'
  s.description      = <<-DESC
temp fake connectivity_web plugin
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/connectivity/connectivity_for_web'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
