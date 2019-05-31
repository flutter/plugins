#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'cloud_functions'
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
<<<<<<< HEAD
  s.dependency 'Firebase/Functions'
  
  s.ios.deployment_target = '8.0'
=======
  s.dependency 'Firebase/Functions', '~> 6.0'
  s.static_framework = true
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
end

