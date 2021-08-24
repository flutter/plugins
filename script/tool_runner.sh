#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Runs the plugin tools from the in-tree source.
function plugin_tools() {
  (pushd "$REPO_DIR/script/tool" && dart pub get && popd) >/dev/null
  dart run "$REPO_DIR/script/tool/bin/flutter_plugin_tools.dart" "$@"
}

ACTIONS=("$@")

BRANCH_NAME="${BRANCH_NAME:-"$(git rev-parse --abbrev-ref HEAD)"}"

# This has to be turned into a list and then split out to the command line,
# otherwise it gets treated as a single argument.
PLUGIN_SHARDING=($PLUGIN_SHARDING)

if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" ${PLUGIN_SHARDING[@]})
else
  echo running "${ACTIONS[@]}"
  (cd "$REPO_DIR" && plugin_tools "${ACTIONS[@]}" --run-on-changed-packages ${PLUGIN_SHARDING[@]})
fi
