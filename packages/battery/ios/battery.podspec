#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'battery'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for accessing information about the battery.'
  s.description      = <<-DESC
Flutter plugin for accessing information about the battery.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/battery'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end
