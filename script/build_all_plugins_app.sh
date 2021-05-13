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

source "$SCRIPT_DIR/common.sh"

# This list should be kept as short as possible, and things should remain here
# only as long as necessary, since in general the goal is for all of the latest
# versions of plugins to be mutually compatible.
#
# An example use case for this list would be to temporarily add plugins while
# updating multiple plugins for a breaking change in a common dependency in
# cases where using a relaxed version constraint isn't possible.
readonly EXCLUDED_PLUGINS_LIST=(
  "plugin_platform_interface" # This should never be a direct app dependency.
)
# Comma-separated string of the list above
readonly EXCLUDED=$(IFS=, ; echo "${EXCLUDED_PLUGINS_LIST[*]}")

ALL_EXCLUDED=($EXCLUDED)

echo "Excluding the following plugins: $ALL_EXCLUDED"

(cd "$REPO_DIR" && plugin_tools all-plugins-app --exclude $ALL_EXCLUDED)

# Master now creates null-safe app code by default; migrate stable so both
# branches are building in the same mode.
if [[ "${CHANNEL}" == "stable" ]]; then
  (cd $REPO_DIR/all_plugins && dart migrate --apply-changes)
fi

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

rm -rf $REPO_DIR/all_plugins/
exit $failures
