#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
set -e
set -x

readonly TARGET_DIR=$1

# The build of Chromium used to test web functionality.
#
# Chromium builds can be located here: https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
readonly CHROMIUM_BUILD=768968
# The ChromeDriver version corresponding to the build above. See
# https://chromedriver.chromium.org/downloads
# for versions mappings when updating Chromium.
readonly CHROME_DRIVER_VERSION=84.0.4147.30

# Install Chromium.
mkdir "$TARGET_DIR"
wget --no-verbose "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2Fchrome-linux.zip?alt=media" -O "$TARGET_DIR"/chromium.zip
unzip "$TARGET_DIR"/chromium.zip -d "$TARGET_DIR"/

# Install ChromeDriver.
readonly DRIVER_ZIP_FILE="$TARGET_DIR/chromedriver.zip"
wget --no-verbose "https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip" -O "$DRIVER_ZIP_FILE"
unzip "$DRIVER_ZIP_FILE" -d "$TARGET_DIR/chromedriver"

# Echo info at the end for ease of debugging.
export CHROME_EXECUTABLE="$TARGET_DIR"/chrome-linux/chrome
echo $CHROME_EXECUTABLE
$CHROME_EXECUTABLE --version
echo "ChromeDriver $CHROME_DRIVER_VERSION"
