#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'url_launcher_macos'
  s.version          = '0.0.1'
  s.summary          = 'Flutter macos plugin for launching a URL.'
  s.description      = <<-DESC
  A macOS implementation of the url_launcher plugin.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/tree/master/packages/url_launcher/url_launcher_macos'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx
  s.osx.deployment_target = '10.11'
end

