#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
require 'yaml'
pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
libraryVersion = pubspec['version'].gsub('+', '-')

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
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/Firestore', '~> 6.0'
  s.static_framework = true

  s.prepare_command = <<-CMD
      echo // Generated file, do not edit > Classes/UserAgent.h
      echo "#define LIBRARY_VERSION @\\"#{libraryVersion}\\"" >> Classes/UserAgent.h
      echo "#define LIBRARY_NAME @\\"flutter-fire-fst\\"" >> Classes/UserAgent.h
    CMD
end
