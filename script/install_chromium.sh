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
#
# Check: https://github.com/flutter/engine/blob/master/lib/web_ui/dev/browser_lock.yaml
readonly CHROMIUM_BUILD=929514

# The correct ChromeDriver is distributed alongside the chromium build above, as
# `chromedriver_linux64.zip`, so no need to hardcode any extra info about it.
readonly DOWNLOAD_ROOT="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2F"

# Install Chromium.
mkdir "$TARGET_DIR"
readonly CHROMIUM_ZIP_FILE="$TARGET_DIR/chromium.zip"
wget --no-verbose "${DOWNLOAD_ROOT}chrome-linux.zip?alt=media" -O "$CHROMIUM_ZIP_FILE"
unzip -q "$CHROMIUM_ZIP_FILE" -d "$TARGET_DIR/"

# Install ChromeDriver.
readonly DRIVER_ZIP_FILE="$TARGET_DIR/chromedriver.zip"
wget --no-verbose "${DOWNLOAD_ROOT}chromedriver_linux64.zip?alt=media" -O "$DRIVER_ZIP_FILE"
unzip -q "$DRIVER_ZIP_FILE" -d "$TARGET_DIR/"
# Rename TARGET_DIR/chromedriver_linux64 to the expected TARGET_DIR/chromedriver
mv -T "$TARGET_DIR/chromedriver_linux64" "$TARGET_DIR/chromedriver"

export CHROME_EXECUTABLE="$TARGET_DIR/chrome-linux/chrome"

# Echo info at the end for ease of debugging.
set +x
echo
readonly CHROMEDRIVER_EXECUTABLE="$TARGET_DIR/chromedriver/chromedriver"
echo "$CHROME_EXECUTABLE"
"$CHROME_EXECUTABLE" --version
echo "$CHROMEDRIVER_EXECUTABLE"
"$CHROMEDRIVER_EXECUTABLE" --version
echo
