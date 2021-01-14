#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'path_provider_linux'
  s.version          = '0.0.1'
  s.summary          = 'No-op implementation of path_provider linux plugin to avoid build issues on iOS'
  s.description      = <<-DESC
  No-op implementation of path_provider linux plugin
  See https://github.com/flutter/flutter/issues/39659
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/master/packages/path_provider/path_provider_linux' }
  s.documentation_url = 'https://pub.dev/packages/path_provider'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'
end