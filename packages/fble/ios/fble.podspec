#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'fble'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Bluetooth Low Energy.'
  s.description      = <<-DESC
Flutter plugin to work with BLE stacks in Android and iOS.
                       DESC
  s.homepage         = 'https://github.com/flutter/plugins/fble'
  s.license          = { :file => '../LICENSE', :type => 'BSD' }
  s.author           = { 'Flutter Team' => 'flutter-dev@googlegroups.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency '!ProtoCompiler'
  s.framework = 'CoreBluetooth'

  protoc = '../example/ios/Pods/!ProtoCompiler/protoc'
  objc_out = 'gen'
  proto_in = '../protos'
  s.prepare_command = <<-CMD
    mkdir -p #{objc_out}
    #{protoc} \
        --objc_out=#{objc_out} \
        --proto_path=#{proto_in} \
        #{proto_in}/*.proto
  CMD

  s.subspec 'Protos' do |ss|
    ss.source_files = 'gen/**/*.pbobjc.{h,m}'
    ss.header_mappings_dir = 'gen'
    ss.requires_arc = false
    ss.dependency 'Protobuf'
  end

  s.pod_target_xcconfig = {
    # This is needed by all pods that depend on Protobuf:
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS=1',
  }

  s.ios.deployment_target = '8.0'
end
