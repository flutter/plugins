#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'share'
  s.version          = '0.5.2'
  s.summary          = 'A Flutter plugin for sharing content from the Flutter app via the platform share sheet.'
  s.description      = <<-DESC
A Flutter plugin for sharing content from the Flutter app via the platform share sheet.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/share'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.ios.deployment_target = '8.0'
end

