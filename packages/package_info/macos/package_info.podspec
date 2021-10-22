#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'package_info'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for querying information about the application package.'
  s.description      = <<-DESC
Flutter plugin for querying information about the application package, based on bundle data.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/package_info'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/package_info' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
