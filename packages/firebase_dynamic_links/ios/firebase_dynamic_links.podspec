#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_dynamic_links'
  s.version          = '0.1.0'
  s.summary          = 'Firebase Dynamic Links plugin for Flutter.'
  s.description      = <<-DESC
Flutter plugin for Google Dynamic Links for Firebase, an app solution for creating and handling
 links across multiple platforms.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/firebase_dynamic_links'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/DynamicLinks'
  s.ios.deployment_target = '8.0'
  s.static_framework = true
end