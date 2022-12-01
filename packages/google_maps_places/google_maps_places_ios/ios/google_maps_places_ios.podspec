#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_maps_places_ios.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_maps_places_ios'
  s.version          = '0.0.1'
  s.summary          = 'The iOS implementation of the google_maps_places plugin.'
  s.description      = <<-DESC
A Flutter plugin that provides Google Maps Places integration.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/main/packages/google_maps_places/google_maps_places/ios' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # GoogleMaps does not support arm64 simulators.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'

  # Dependencies
  s.dependency 'GooglePlaces'
  s.static_framework = true
end
