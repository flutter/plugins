#!/bin/bash
wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
mkdir android-sdk
unzip -qq sdk-tools-linux-3859397.zip -d android-sdk
export ANDROID_HOME=`pwd`/android-sdk
export PATH=`pwd`/android-sdk/tools/bin:$PATH
mkdir -p /home/travis/.android # silence sdkmanager warning
echo 'count=0' > /home/travis/.android/repositories.cfg # silence sdkmanager warning
        # suppressing output of sdkmanager to keep log under 4MB (travis limit)
echo y | sdkmanager "tools" >/dev/null
echo y | sdkmanager "platform-tools" >/dev/null
echo y | sdkmanager "build-tools;26.0.3" >/dev/null
echo y | sdkmanager "platforms;android-26" >/dev/null
echo y | sdkmanager "extras;android;m2repository" >/dev/null
echo y | sdkmanager "extras;google;m2repository" >/dev/null
echo y | sdkmanager "patcher;v4" >/dev/null
sdkmanager --list
wget http://services.gradle.org/distributions/gradle-4.1-bin.zip
unzip -qq gradle-4.1-bin.zip
export GRADLE_HOME=$PWD/gradle-4.1
export PATH=$GRADLE_HOME/bin:$PATH
gradle -v
git clone https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:`pwd`/flutter/bin/cache/dart-sdk/bin:$PATH
flutter doctor
pub global activate flutter_plugin_tools
