#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'cloud_firestore'
  s.version          = '0.0.1'
  s.summary          = 'Firestore plugin for Flutter.'
  s.description      = <<-DESC
Firestore plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/flutter/firestore'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.ios.deployment_target = '8.0'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Database'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Auth'
  s.dependency 'Firebase/Firestore'
  s.static_framework = true
end
