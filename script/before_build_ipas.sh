#!/bin/bash
brew update
brew install libimobiledevice
brew install ideviceinstaller
brew install ios-deploy
pod repo update
gem update cocoapods
git clone https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:`pwd`/flutter/bin/cache/dart-sdk/bin:$PATH
flutter doctor
pub global activate flutter_plugin_tools
