#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
# Run `pod lib lint path_provider_windows.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'path_provider_windows'
  s.version          = '0.0.1'
  s.summary          = 'path_provider_windows iOS stub'
  s.description      = <<-DESC
  No-op implementation of the windows path_provider plugin to avoid build issues on iOS
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/path_provider/path_provider_windows' }
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
