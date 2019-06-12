#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_core'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Core'
  s.ios.deployment_target = '8.0'
  s.static_framework = true

  s.prepare_command = <<-CMD
    PUBSPEC_VERSION=`cat ../pubspec.yaml | grep version: | sed 's/version: //g'`
    echo // Generated file, do not edit > Classes/version.h
    echo "#define LIBRARY_VERSION @\\"$PUBSPEC_VERSION\\"" >> Classes/version.h
  CMD

end
