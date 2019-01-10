#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_in_app_messaging'
  s.version          = '0.0.1'
  s.summary          = 'Firebase In-App Messaging plugin for Flutter.'
  s.description      = <<-DESC
Flutter plugin for Firebase In-App Messaging, which helps you engage users who are actively using your app by sending them targeted and contextual messages that nudge them to complete key in-app actions.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/firebase_in_app_messaging'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/InAppMessaging'
  s.ios.deployment_target = '8.0'
  s.static_framework = true
end
