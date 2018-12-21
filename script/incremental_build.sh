#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

source "$SCRIPT_DIR/common.sh"

# Set some default actions if run without arguments.
ACTIONS=("$@")
if [[ "${#ACTIONS[@]}" == 0 ]]; then
  ACTIONS=("test" "analyze" "java-test")
fi

if [[ "${BRANCH_NAME}" == "master" ]]; then
  echo "Running for all packages"
  (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
else
  # Sets CHANGED_PACKAGES
  check_changed_packages

  if [[ "$CHANGED_PACKAGES" == "" ]]; then
    echo "Running for all packages"
    (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" $PLUGIN_SHARDING)
  else
    # @todo move this to flutter_plugin_tools
    if [[ "$@" == "test" ]]; then
      PACKAGE=${CHANGED_PACKAGE_LIST[0]} $SCRIPT_DIR/test_coverage_single_package.sh
    else
      (cd "$REPO_DIR" && pub global run flutter_plugin_tools "${ACTIONS[@]}" --plugins="$CHANGED_PACKAGES" $PLUGIN_SHARDING)
    fi
  fi
fi
