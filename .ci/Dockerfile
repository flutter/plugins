
FROM cirrusci/flutter:latest

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository" \
    "system-images;android-21;default;armeabi-v7a"

RUN yes | sdkmanager --licenses
