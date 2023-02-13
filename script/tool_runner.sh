#!/bin/bash
# Copyright 2013 The Flutter Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

set -e

# WARNING! Do not remove this script, or change its behavior, unless you have
# verified that it will not break the dart-lang analysis run of this
# repository: https://github.com/dart-lang/sdk/blob/main/tools/bots/flutter/analyze_flutter_plugins.sh

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
readonly REPO_DIR="$(dirname "$SCRIPT_DIR")"


# The tool expects to be run from the repo root.
# PACKAGE_SHARDING is (optionally) set from Cirrus. See .cirrus.yml
cd "$REPO_DIR"
# Ensure that the tooling has been activated.
.ci/scripts/prepare_tool.sh

dart pub global run flutter_plugin_tools "$@" \
  --packages-for-branch \
  --log-timing \
  $PACKAGE_SHARDING
