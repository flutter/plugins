#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_admob'
  s.version          = '0.0.1'
  s.summary          = 'Firebase Admob plugin for Flutter.'
  s.description      = <<-DESC
Firebase Admob plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/firebase_admob'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/AdMob'

  s.ios.deployment_target = '8.0'

  s.pod_target_xcconfig = {
   'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/**',
   'OTHER_LDFLAGS' => '$(inherited) -undefined dynamic_lookup'
  }
end
