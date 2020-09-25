Pod::Spec.new do |s|
  s.name             = 'battery_macos'
  s.version          = '0.0.1'
  s.summary          = 'No-op implementation of the macos battery plugin to avoid build issues on iOS'
  s.description      = <<-DESC
  No-op implementation of the macos battery plugin to avoid build issues on iOS
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/battery/battery_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'
end