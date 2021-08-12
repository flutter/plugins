#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

#  Usage:
#
#   ./script/build_all_plugins_app.sh apk
#   ./script/build_all_plugins_app.sh ios

# This script builds the app in flutter/plugins/example/all_plugins to make
# sure all first party plugins can be compiled together.

# So that users can run this script from anywhere and it will work as expected.
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null && pwd)"

readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

function error() {
  echo "$@" 1>&2
}

failures=0

BUILD_MODES=("debug" "release")
# Web doesn't support --debug for builds.
if [[ "$1" == "web" ]]; then
  BUILD_MODES=("release")
fi

for version in "${BUILD_MODES[@]}"; do
  echo "Building $version..."
  (cd $REPO_DIR/all_plugins && flutter build $@ --$version)

  if [ $? -eq 0 ]; then
    echo "Successfully built $version all_plugins app."
    echo "All first-party plugins compile together."
  else
    error "Failed to build $version all_plugins app."
    error "This indicates a conflict between two or more first-party plugins."
    failures=$(($failures + 1))
  fi
done

exit $failures
