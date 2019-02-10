

#
# NOTE: This podspec is NOT to be published. It is only used as a local source!
#

Pod::Spec.new do |s|
s.name             = 'location_background_plugin'
s.version          = '0.0.1'
s.summary          = 'High-performance, high-fidelity mobile apps.'
s.description      = <<-DESC
Flutter provides an easy and productive way to build and deploy high-performance mobile apps for Android and iOS.
DESC
s.homepage         = 'https://flutter.io'
s.license          = { :type => 'MIT' }
s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
s.source           = { :path => '.'}
s.source_files = 'Classes/**/*'
s.public_header_files = 'Classes/**/*.h'
s.dependency 'Flutter'
s.ios.deployment_target = '8.0'
# s.vendored_frameworks = 'Flutter.framework'
end
