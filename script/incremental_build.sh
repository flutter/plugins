#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Plugins that are excluded from this task.
ALL_EXCLUDED=("")

# Plugins that deliberately use their own analysis_options.yaml.
#
# This list should only be deleted from, never added to. This only exists
# because we adopted stricter analysis rules recently and needed to exclude
# already failing packages to start linting the repo as a whole.
#
# TODO(mklim): Remove everything from this list. https://github.com/flutter/flutter/issues/45440
CUSTOM_ANALYSIS_PLUGINS=(
)

# Comma-separated string of the list above
readonly CUSTOM_FLAG=$(IFS=, ; echo "${CUSTOM_ANALYSIS_PLUGINS[*]}")
# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("analyze" "--custom-analysis" "$CUSTOM_FLAG" "test" "java-test")
elif [[ "${ACTIONS[@]}" == "analyze" ]]; then
  ACTIONS=("analyze" "--custom-analysis" "$CUSTOM_FLAG")
fi

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"

# This has to be turned into a list and then split out to the command line,
# otherwise it gets treated as a single argument.
PLUGIN_SHARDING=($PLUGIN_SHARDING)

if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" --exclude="$ALL_EXCLUDED" ${PLUGIN_SHARDING[@]})
else
  # Sets CHANGED_PACKAGES
  check_changed_packages

  if [[ "$CHANGED_PACKAGES" == "" ]]; then
    echo "No changes detected in packages."
    echo "Running for all packages"
    (cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" --exclude="$ALL_EXCLUDED" ${PLUGIN_SHARDING[@]})
  else
    echo running "${ACTIONS[@]}"
    (cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" --exclude="$ALL_EXCLUDED" ${PLUGIN_SHARDING[@]})
  fi
fi
