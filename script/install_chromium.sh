#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script may be run as:
# $ CHROME_DOWNLOAD_DIR=./whatever script/install_chromium.sh
set -e
set -x

# The target directory where chromium is going to be downloaded
: "${CHROME_DOWNLOAD_DIR:=/tmp/chromium}" # Default value for the CHROME_DOWNLOAD_DIR env.

# The build of Chromium used to test web functionality.
#
# Chromium builds can be located here: https://commondatastorage.googleapis.com/chromium-browser-snapshots/index.html?prefix=Linux_x64/
#
# Check: https://github.com/flutter/engine/blob/master/lib/web_ui/dev/browser_lock.yaml
: "${CHROMIUM_BUILD:=950363}" # Default value for the CHROMIUM_BUILD env.

# Convenience defaults for CHROME_EXECUTABLE and CHROMEDRIVER_EXECUTABLE. These
# two values should be set in the environment from CI, so this script can validate
# that it has completed downloading chrome and driver successfully (and the expected
# files are executable)
: "${CHROME_EXECUTABLE:=$CHROME_DOWNLOAD_DIR/chrome-linux/chrome}"
: "${CHROMEDRIVER_EXECUTABLE:=$CHROME_DOWNLOAD_DIR/chromedriver/chromedriver}"

# The correct ChromeDriver is distributed alongside the chromium build above, as
# `chromedriver_linux64.zip`, so no need to hardcode any extra info about it.
readonly DOWNLOAD_ROOT="https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2F"

# Install Chromium.
mkdir "$CHROME_DOWNLOAD_DIR"
readonly CHROMIUM_ZIP_FILE="$CHROME_DOWNLOAD_DIR/chromium.zip"
wget --no-verbose "${DOWNLOAD_ROOT}chrome-linux.zip?alt=media" -O "$CHROMIUM_ZIP_FILE"
unzip -q "$CHROMIUM_ZIP_FILE" -d "$CHROME_DOWNLOAD_DIR/"

# Install ChromeDriver.
readonly DRIVER_ZIP_FILE="$CHROME_DOWNLOAD_DIR/chromedriver.zip"
wget --no-verbose "${DOWNLOAD_ROOT}chromedriver_linux64.zip?alt=media" -O "$DRIVER_ZIP_FILE"
unzip -q "$DRIVER_ZIP_FILE" -d "$CHROME_DOWNLOAD_DIR/"
# Rename CHROME_DOWNLOAD_DIR/chromedriver_linux64 to the expected CHROME_DOWNLOAD_DIR/chromedriver
mv -T "$CHROME_DOWNLOAD_DIR/chromedriver_linux64" "$CHROME_DOWNLOAD_DIR/chromedriver"

# Echo info at the end for ease of debugging.
#
# exports from this script cannot be used elsewhere in the .cirrus.yml file.
set +x
echo
echo "$CHROME_EXECUTABLE"
"$CHROME_EXECUTABLE" --version
echo "$CHROMEDRIVER_EXECUTABLE"
"$CHROMEDRIVER_EXECUTABLE" --version
echo
