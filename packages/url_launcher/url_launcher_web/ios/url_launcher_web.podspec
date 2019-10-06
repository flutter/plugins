#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'url_launcher_web'
  s.version          = '0.0.1'
  s.summary          = 'No-op implementation of url_launcher_web web plugin to avoid build issues on iOS'
  s.description      = <<-DESC
temp fake url_launcher_web plugin
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher_web'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end
