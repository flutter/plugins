#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

function join { local IFS="$1"; shift; echo "$*"; }

# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("test" "analyze" "java-test")
fi

# Sets CHANGED_PACKAGES
check_changed_packages

if [[ "$CHANGED_PACKAGES" == "" || "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  CHANGED_PACKAGES=$(join , $(ls packages))
fi
# @todo move this to flutter_plugin_tools
if [[ "$@" == "test" ]]; then
  PACKAGE=${CHANGED_PACKAGE_LIST[0]} $SCRIPT_DIR/test_coverage_single_package.sh
else
  (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" $PLUGIN_SHARDING)
fi
