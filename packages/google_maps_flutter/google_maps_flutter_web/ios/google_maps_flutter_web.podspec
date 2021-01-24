#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_maps_flutter_web.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_maps_flutter_web'
  s.version          = '0.1.0'
  s.summary          = 'No-op implementation of google maps flutter web plugin to avoid build issues on iOS'
  s.description      = <<-DESC
temp fake google_maps_flutter_web plugin
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/google_maps_flutter/google_maps_flutter_web'
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
