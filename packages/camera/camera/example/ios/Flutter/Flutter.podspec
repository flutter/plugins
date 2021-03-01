#
# NOTE: This podspec is NOT to be published. It is only used as a local source!
#       This is a generated file; do not edit or check into version control.
#

Pod::Spec.new do |s|
  s.name             = 'Flutter'
  s.version          = '1.0.0'
  s.summary          = 'High-performance, high-fidelity mobile apps.'
  s.homepage         = 'https://flutter.io'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Flutter Dev Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :git => 'https://github.com/flutter/engine', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  # Framework linking is handled by Flutter tooling, not CocoaPods.
  # Add a placeholder to satisfy `s.dependency 'Flutter'` plugin podspecs.
  s.vendored_frameworks = 'path/to/nothing'
end
