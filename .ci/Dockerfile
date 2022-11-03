# The Flutter version is not important here, since the CI scripts update Flutter
# before running. What matters is that the base image is pinned to minimize
# unintended changes when modifying this file.
# This is the hash for the 3.0.0 image.
FROM cirrusci/flutter@sha256:0224587bba33241cf908184283ec2b544f1b672d87043ead1c00521c368cf844

RUN apt-get update -y

# Set up Firebase Test Lab requirements.
RUN apt-get install -y --no-install-recommends gnupg
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update && apt-get install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

# Install formatter for C-based languages.
RUN apt-get install -y clang-format

# Install Linux desktop requirements:
# - build tools.
RUN apt-get install -y clang cmake ninja-build file pkg-config
# - libraries.
RUN apt-get install -y libgtk-3-dev libblkid-dev liblzma-dev libgcrypt20-dev
# - xvfb to allow running headless.
RUN apt-get install -y xvfb libegl1-mesa

# Install Chrome and make it the default browser, for url_launcher tests.
# IMPORTANT: Web tests should use a pinned version of Chromium, not this, since
# this isn't pinned, so any time the docker image is re-created the version of
# Chrome may change.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y --no-install-recommends google-chrome-stable
# Make Chrome the default for http:, https: and file:.
RUN apt-get install -y xdg-utils
RUN xdg-settings set default-web-browser google-chrome.desktop
RUN xdg-mime default google-chrome.desktop inode/directory
