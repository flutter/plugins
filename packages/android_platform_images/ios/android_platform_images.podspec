#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint android_platform_images.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'android_platform_images'
  s.version          = '0.0.1'
  s.summary          = ' A plugin to share images from android to flutter in add-to-app setups.'
  s.description      = <<-DESC
 A plugin to share images from android to flutter in add-to-app setups.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
