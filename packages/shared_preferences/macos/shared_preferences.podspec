#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'shared_preferences'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for reading and writing simple key-value pairs.'
  s.description      = <<-DESC
A Flutter plugin for reading and writing simple key-value pairs.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/shared_preferences'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx
  s.osx.deployment_target = '10.12'
end

