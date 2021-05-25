FROM cirrusci/flutter:stable

RUN sudo apt-get update -y

RUN sudo apt-get install -y --no-install-recommends gnupg

# Add repo for gcloud sdk and install it
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
    sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

RUN sudo apt-get update && sudo apt-get install -y google-cloud-sdk && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true

RUN yes | sdkmanager \
    "platforms;android-27" \
    "build-tools;27.0.3" \
    "extras;google;m2repository" \
    "extras;android;m2repository"

RUN yes | sdkmanager --licenses

# Install formatter.
RUN sudo apt-get install -y clang-format

# Install xvfb to allow running headless
RUN sudo apt-get install -y xvfb libegl1-mesa
# Install Linux desktop build tool requirements.
RUN sudo apt-get install -y clang cmake ninja-build file pkg-config
# Install necessary libraries.
RUN sudo apt-get install -y libgtk-3-dev libblkid-dev liblzma-dev libgcrypt20-dev

# Add repo for Google Chrome and install it
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | sudo tee /etc/apt/sources.list.d/google-chrome.list
RUN sudo apt-get update && sudo apt-get install -y --no-install-recommends google-chrome-stable

# Make Chrome the default so http: has a handler for url_launcher tests.
RUN sudo apt-get install -y xdg-utils
RUN xdg-settings set default-web-browser google-chrome.desktop
