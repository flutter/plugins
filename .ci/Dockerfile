# The Flutter version is not important here, since the CI scripts update Flutter
# before running. What matters is that the base image is pinned to minimize
# unintended changes when modifying this file.
FROM cirrusci/flutter@sha256:505fe8bce2896c75b4df9ccf500b1604155bf932af7465ffcc66fcae8612f82f

RUN apt-get update -y

RUN apt-get install -y --no-install-recommends gnupg

# Add repo for gcloud sdk and install it
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN apt-get update && apt-get install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository"

RUN yes | sdkmanager --licenses

# Install formatter.
RUN apt-get install -y clang-format

# Install xvfb to allow running headless
RUN apt-get install -y xvfb libegl1-mesa
# Install Linux desktop build tool requirements.
RUN apt-get install -y clang cmake ninja-build file pkg-config
# Install necessary libraries.
RUN apt-get install -y libgtk-3-dev libblkid-dev liblzma-dev libgcrypt20-dev

# Add repo for Google Chrome and install it
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y --no-install-recommends google-chrome-stable

# Make Chrome the default so http: and file: has a handler for url_launcher tests.
RUN apt-get install -y xdg-utils
RUN xdg-settings set default-web-browser google-chrome.desktop
RUN xdg-mime default google-chrome.desktop inode/directory
