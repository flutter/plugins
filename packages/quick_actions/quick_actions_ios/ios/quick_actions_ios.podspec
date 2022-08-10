#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'quick_actions_ios'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Quick Actions'
  s.description      = <<-DESC
This Flutter plugin allows you to manage and interact with the application's home screen quick actions.
Downloaded by pub (not CocoaPods).
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :http => 'https://github.com/flutter/plugins/tree/main/packages/quick_actions' }
  s.documentation_url = 'https://pub.dev/packages/quick_actions'
  s.source_files = 'Classes/**/*.{h,m}'
  s.public_header_files = 'Classes/*.h'
  s.private_header_files = 'Classes/PrivateHeaders/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.module_map = 'Classes/QuickActionsPlugin.modulemap'
end
