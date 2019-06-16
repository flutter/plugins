#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = pubspec['version']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.author           = pubspec['author']
  s.summary          = 'Firestore plugin for Flutter.'
  s.license          = { :file => '../LICENSE' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.ios.deployment_target = '8.0'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Firestore', '~> 6.0'
  s.static_framework = true
  # Generate an empty resource bundle so that Pod metadata can be read at runtime
  s.resource_bundle = { pubspec['name'] => 'Pod/Assets/*' }
end
