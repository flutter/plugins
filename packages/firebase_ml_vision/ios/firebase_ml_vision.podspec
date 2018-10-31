#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_ml_vision'
  s.version          = '0.1.1'
  s.summary          = 'Flutter plugin for Google ML Vision for Firebase.'
  s.description      = <<-DESC
An SDK that brings Google's machine learning expertise to Android and iOS apps in a powerful yet
 easy-to-use package.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/firebase_ml_vision'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/MLVision'
  s.dependency 'Firebase/MLVisionBarcodeModel'
  s.dependency 'Firebase/MLVisionFaceModel'
  s.dependency 'Firebase/MLVisionLabelModel'
  s.dependency 'Firebase/MLVisionTextModel'
  s.ios.deployment_target = '8.0'
  s.static_framework = true
end
