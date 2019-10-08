#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'url_launcher'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for launching a URL.'
  s.description      = <<-DESC
A Flutter plugin for making the underlying platform (Android or iOS) launch a URL.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/url_launcher'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

