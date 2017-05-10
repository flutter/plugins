#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_messaging'
  s.version          = '0.0.1'
  s.summary          = 'Firebase Cloud Messaging plugin for Flutter.'
  s.description      = <<-DESC
Firebase Cloud Messaging plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/flutter/firebase_messaging'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Google Inc.' => 'goderbauer@google.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Messaging'
  
  s.ios.deployment_target = '8.0'
end

