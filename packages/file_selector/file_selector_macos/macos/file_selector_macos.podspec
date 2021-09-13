#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'file_selector_macos'
  s.version          = '0.0.1'
  s.summary          = 'macOS implementation of file_selector.'
  s.description      = <<-DESC
Displays native macOS open and save panels.
                       DESC
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.homepage         = 'https://github.com/google/flutter-desktop-embedding/tree/master/plugins/file_selector'
  s.author           = { 'Flutter Desktop Embedding Developers' => 'flutter-desktop-embedding-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/google/flutter-desktop-embedding/tree/master/plugins/file_selector/file_selector_macos' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
