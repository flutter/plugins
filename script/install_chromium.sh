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
# When updating this, the ChromeDriver version passed to web_driver_installer
# in .cirrus.yaml must be updated as well.
CHROMIUM_BUILD=768968

mkdir "$TARGET_DIR"
wget "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F${CHROMIUM_BUILD}%2Fchrome-linux.zip?alt=media" -O "$TARGET_DIR"/chromium.zip
unzip "$TARGET_DIR"/chromium.zip -d "$TARGET_DIR"/
export CHROME_EXECUTABLE="$TARGET_DIR"/chrome-linux/chrome
echo $CHROME_EXECUTABLE
$CHROME_EXECUTABLE --version
