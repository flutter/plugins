# Flutter (https://flutter.io) Developement Environment for Linux
# ===============================================================
#
# This environment passes all Linux Flutter Doctor checks and is sufficient
# for building Android applications and running Flutter tests.
#
# To build iOS applications, a Mac development environment is necessary.
#
# This includes applications and sdks that are needed only by the CI system
# for performing pushes to production, and so this image is quite a bit larger
# than strictly needed for just building Flutter apps.

FROM debian:stretch
MAINTAINER Flutter Developers <flutter-dev@googlegroups.com>

RUN apt-get update -y
RUN apt-get upgrade -y

# Install basics
RUN apt-get install -y --no-install-recommends \
  coreutils \
  git \
  wget \
  curl \
  unzip \
  ca-certificates \
  gnupg \
  software-properties-common

# Add llvm repository.
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN apt-add-repository "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-5.0 main" && apt-get update

# Install the rest of the dependencies.
RUN apt-get install -y --no-install-recommends --allow-unauthenticated \
  build-essential \
  clang-format-5.0 \
  default-jdk-headless \
  lib32stdc++6 \
  libglu1-mesa \
  libstdc++6 \
  locales \
  fonts-droid-fallback

# Install the Android SDK Dependency.
ENV ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV ANDROID_TOOLS_ROOT="/opt/android_sdk"
RUN mkdir -p "${ANDROID_TOOLS_ROOT}"
RUN mkdir -p ~/.android
# Silence warning.
RUN touch ~/.android/repositories.cfg
ENV ANDROID_SDK_ARCHIVE="${ANDROID_TOOLS_ROOT}/archive"
RUN wget --progress=dot:giga "${ANDROID_SDK_URL}" -O "${ANDROID_SDK_ARCHIVE}"
RUN unzip -q -d "${ANDROID_TOOLS_ROOT}" "${ANDROID_SDK_ARCHIVE}"
# Suppressing output of sdkmanager to keep log size down
# (it prints install progress WAY too often).
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "tools" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "build-tools;28.0.0" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "platforms;android-28" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "platform-tools" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "extras;android;m2repository" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "extras;google;m2repository" > /dev/null
RUN yes "y" | "${ANDROID_TOOLS_ROOT}/tools/bin/sdkmanager" "patcher;v4" > /dev/null
RUN rm "${ANDROID_SDK_ARCHIVE}"
ENV PATH="${ANDROID_TOOLS_ROOT}/tools/bin:${ANDROID_TOOLS_ROOT}/tools:${PATH}"
# Silence warnings when accepting android licenses.
RUN mkdir -p ~/.android
RUN touch ~/.android/repositories.cfg

# Setup gradle
ENV GRADLE_ROOT="/opt/gradle"
RUN mkdir -p "${GRADLE_ROOT}"
ENV GRADLE_ARCHIVE="${GRADLE_ROOT}/gradle.zip"
ENV GRADLE_URL="http://services.gradle.org/distributions/gradle-4.4-bin.zip"
RUN wget --progress=dot:giga "$GRADLE_URL" -O "${GRADLE_ARCHIVE}"
RUN unzip -q -d "${GRADLE_ROOT}" "${GRADLE_ARCHIVE}"
ENV PATH="$GRADLE_ROOT/bin:$PATH"

# Set locale to en_US.UTF-8
RUN dpkg-reconfigure locales
RUN locale-gen "en_US" "en_US.UTF-8" "C.UTF-8" && /usr/sbin/update-locale LANG="C.UTF-8"
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
ENV LC_ALL="C.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

# Set the pub cache so it's not in the home directory for root.
ENV PUB_CACHE="/opt/pub-cache"
ENV FLUTTER_ROOT="/opt/flutter sdk"
RUN git clone -b beta https://github.com/flutter/flutter "${FLUTTER_ROOT}"
ENV PATH="$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$FLUTTER_ROOT/bin:$PUB_CACHE/bin:${PATH}"
ENV ANDROID_HOME="${ANDROID_TOOLS_ROOT}"

# Turn off analytics for bots.
RUN flutter config --no-analytics

# Perform a flutter upgrade on master: this will happen again for each build,
# but doing it here too will warm the pub cache with packages for those runs.
RUN flutter channel master
RUN flutter upgrade

# Perform an artifact precache so that no extra assets need to be downloaded on demand.
RUN flutter precache

# Activate the plugin tools
RUN pub global activate flutter_plugin_tools

# Accept licenses.
RUN yes "y" | flutter doctor --android-licenses

# Perform a doctor run.
RUN flutter doctor -v

ENTRYPOINT [ "flutter" ]

