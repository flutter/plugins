#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint shared_preferences_launcher_linux.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'shared_preferences_linux'
  s.version          = '0.0.1'
  s.summary          = 'shared_preferences_linux iOS stub'
  s.description      = <<-DESC
  No-op implementation of the Linux shared_preferences plugin to avoid build issues on iOS
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences/shared_preferences_linux' }
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
