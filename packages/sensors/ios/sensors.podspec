#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'sensors'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Sensors'
  s.description      = <<-DESC
A Flutter plugin to access the accelerometer and gyroscope sensors.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/sensors' }
  s.documentation_url = 'https://pub.dev/packages/sensors'
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  
  s.platform = :ios, '8.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
end

