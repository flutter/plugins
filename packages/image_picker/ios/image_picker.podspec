#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'image_picker'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin that shows an image picker.'
  s.description      = <<-DESC
Flutter plugin that shows an image picker.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/image_picker'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.ios.deployment_target = '8.0'
  s.dependency 'Flutter'
end
