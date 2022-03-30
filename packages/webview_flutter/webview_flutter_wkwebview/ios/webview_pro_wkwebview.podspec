#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'webview_pro_wkwebview'
  s.version          = '2.7.1+1'
  s.summary          = 'A WebView Plugin for Flutter.'
  s.description      = <<-DESC
A Flutter plugin that provides a WebView widget.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/wenzhiming/flutter-plugins.git'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'wenzhiming' => 'wenzhiming@gmail.com' }
  s.source           = { :http => 'https://github.com/wenzhiming/flutter-plugins/tree/main/packages/webview_flutter/webview_flutter_wkwebview' }
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/**/*.h'
  s.module_map = 'Classes/FlutterWebView.modulemap'
  s.dependency 'Flutter'

  s.platform = :ios, '9.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
