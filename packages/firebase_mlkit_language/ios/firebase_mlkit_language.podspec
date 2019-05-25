#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'firebase_mlkit_language'
  s.version          = '0.0.1'
  s.summary          = 'Firebase ML Kit Language Plugin for Flutter'
  s.description      = <<-DESC
Firebase ML Kit Language Plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/rishab2113/firebase_mlkit_language/tree/master'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rishab Nayak' => 'rishab@bu.edu' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'Firebase'
  s.dependency 'Firebase/Core'
  s.dependency 'Firebase/MLCommon'
  s.dependency 'Firebase/MLNLTranslate'
  s.dependency 'Firebase/MLNLLanguageID'
  s.dependency 'Firebase/MLNaturalLanguage'
  s.ios.deployment_target = '9.0'
  s.static_framework = true
end
