Pod::Spec.new do |s|
  s.name             = 'battery_macos'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for accessing information about the battery.'
  s.description      = <<-DESC
MacOS implementation of the battery plugin
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/battery/battery_macos'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/battery/battery_macos' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end